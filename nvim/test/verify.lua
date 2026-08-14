-- nvim/test/verify.lua
-- Headless verification harness for the nvim config.
-- Sourced via: nvim --headless +"source ./nvim/test/verify.lua"
-- (runs AFTER init.lua, which has bootstrapped lazy.nvim).
--
-- This script:
--   1. Disables mason auto-install so the test needs no mason network
--      and never hangs on the triple-installer race.
--   2. Runs a synchronous `Lazy! sync` so all plugins are installed at
--      their pinned/version commits before loading.
--   3. Captures every error reported via vim.notify / :messages.
--   4. Force-loads every lazy plugin (exercises all config functions).
--   5. Opens .lua / .go / .md sample files to trigger BufReadPost + ftplugin.
--   6. Exits non-zero (cquit! 1) if any confirmable error was captured.

local VERIFY_DIR = debug.getinfo(1, "S").source:match("@(.*/)") or "./nvim/test/"
local SAMPLES = VERIFY_DIR .. "samples/"

-- Patterns that confirm a real defect (not a benign warning).
local FAIL_PATTERNS = {
  "E%d%d%d%d?", -- nvim error codes: E5108, E5113, ...
  "attempt to (index|call)", -- "attempt to index a nil value"
  "module%s+.- not found", -- "module 'nvim-treesitter.configs' not found"
  "Failed to source", -- "Failed to source <plugin>"
  "assertion", -- mason race: "assertion failed"
  "Package is already installing", -- mason triple-installer race
  "cannot open%-", -- "cannot open-load" lazy errors
  "error detected while", -- nvim's "Error detected while processing"
  "Vim%(E%w+%):", -- Vim:E9 etc.
}

local errs = {}
_G.__VERIFY_ERRS = errs

-- Capture vim.notify (plugins report errors here).
local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg ~= "" then
    errs[#errs + 1] = msg
  elseif type(msg) == "table" and msg.message then
    errs[#errs + 1] = msg.message
  end
  -- Still forward so :messages accumulates it.
  if orig_notify then
    return orig_notify(msg, level, opts)
  end
end

-- Capture vim.api.nvim_echo error output (the nvim error path).
local orig_echo = vim.api.nvim_echo
vim.api.nvim_echo = function(chunks, history, opts)
  local text = {}
  for _, chunk in ipairs(chunks or {}) do
    if type(chunk) == "table" then
      text[#text + 1] = chunk[1] or ""
    else
      text[#text + 1] = tostring(chunk)
    end
  end
  local joined = table.concat(text)
  if joined ~= "" then
    errs[#errs + 1] = joined
  end
  return orig_echo(chunks, history, opts)
end

------------------------------------------------------------------------
-- 1. Disable mason auto-install so the harness needs no mason network.
------------------------------------------------------------------------
-- Remove any leftover autocmd that triggers package installs.
pcall(vim.api.nvim_clear_autocmds, { event = "User", pattern = "LazyDone" })
vim.g.mason_tool_installer_run_on_start = false
vim.g.mason_tool_installer_disable = true

-- Stub mason's install entry point so that any plugin config which calls
-- :MasonInstall / mason-lspconfig ensure_installed is a no-op in the test.
-- This makes the harness deterministic (no network, no package races).
pcall(function()
  local installer = require "mason-registry.installer"
  installer.install = function()
    return {
      receive = function()
        return {
          get_or_throw = function()
            return nil
          end,
        }
      end,
    }
  end
end)

-- Also stub the direct Package:install path used by some flows.
pcall(function()
  local pkg = require "mason-core.package"
  if pkg and pkg.Package then
    local Orig = pkg.Package
    -- no-op install on the class if it exists
    if Orig.install then
      Orig.install = function(self)
        return self
      end
    end
  end
end)

------------------------------------------------------------------------
-- 2. Ensure every plugin is installed at its pinned/version commit.
------------------------------------------------------------------------
local lockfile = vim.fn.stdpath("data") .. "/lazy/lazy-lock.json"
if vim.fn.filereadable(lockfile) == 0 then
  vim.cmd("Lazy! sync")
end
-- Lazy may have scheduled UI; let the dust settle.
vim.wait(500, function() end, 20, false)

------------------------------------------------------------------------
-- 3. Force-load every lazy plugin to exercise all config functions.
------------------------------------------------------------------------
local ok_lazy, lazy = pcall(require, "lazy")
local loaded_count = 0
local load_errors = {}
if ok_lazy and lazy and lazy.plugins then
  for _, spec in ipairs(lazy.plugins()) do
    local name = spec.name
    if name then
      local ok, err = pcall(lazy.load, { plugins = { name } })
      if ok then
        loaded_count = loaded_count + 1
      else
        load_errors[#load_errors + 1] = name .. ": " .. tostring(err)
      end
    end
  end
else
  load_errors[#load_errors + 1] = "lazy.nvim API unavailable"
end

------------------------------------------------------------------------
-- 4. Open sample files to trigger BufReadPost + filetype plugins.
------------------------------------------------------------------------
local sample_files = {
  SAMPLES .. "sample.lua",
  SAMPLES .. "sample.go",
  SAMPLES .. "sample.md",
}

for _, f in ipairs(sample_files) do
  --edit triggers BufReadPost autocommands (tree-setter, textsubjects, etc.)
  pcall(vim.cmd, "edit " .. vim.fn.fnameescape(f))
end

-- Let any async handlers (lsp, treesitter attach) run.
vim.wait(4000, function() end, 50, false)

------------------------------------------------------------------------
-- 5. Collect :messages (catches errors emitted outside vim.notify)
--    and the captured error list.
------------------------------------------------------------------------
-- Highlighter/LSP errors fire on deferred callbacks up to ~1s after a
-- buffer is opened; collect twice with a wait to close the window.
local all_lines = {}

local function collect_messages()
  local msgs = vim.api.nvim_exec2("messages", { output = true })
  if msgs and msgs.output and msgs.output ~= "" then
    for line in msgs.output:gmatch("[^\r\n]+") do
      all_lines[#all_lines + 1] = line
    end
  end
  for _, e in ipairs(errs) do
    if type(e) == "string" then
      for line in e:gmatch("[^\r\n]+") do
        all_lines[#all_lines + 1] = line
      end
    end
  end
  for _, le in ipairs(load_errors) do
    all_lines[#all_lines + 1] = "LOAD: " .. le
  end
end

collect_messages()
vim.wait(1500, function() end, 50, false)
collect_messages()

------------------------------------------------------------------------
-- 6. Decide pass/fail.
------------------------------------------------------------------------
local failures = {}
for _, line in ipairs(all_lines) do
  for _, pat in ipairs(FAIL_PATTERNS) do
    if line:match(pat) then
      failures[#failures + 1] = line
      break
    end
  end
end

local function dedupe(t)
  local seen = {}
  local out = {}
  for _, v in ipairs(t) do
    if not seen[v] then
      seen[v] = true
      out[#out + 1] = v
    end
  end
  return out
end

failures = dedupe(failures)

local total_plugins = 0
if ok_lazy and lazy and lazy.plugins then
  total_plugins = #lazy.plugins()
end

if #failures > 0 then
  print("VERIFY: FAIL (" .. #failures .. " error(s), " .. total_plugins .. " plugins, " .. loaded_count .. " loaded)")
  print("---")
  for _, f in ipairs(failures) do
    print("  " .. f)
  end
  -- Restore notify so the cquit message isn't swallowed.
  vim.notify = orig_notify
  vim.api.nvim_echo = orig_echo
  vim.cmd("cquit! 1")
else
  print("VERIFY: OK (" .. total_plugins .. " plugins, " .. loaded_count .. " loaded, 0 errors)")
  vim.cmd("qa!")
end
