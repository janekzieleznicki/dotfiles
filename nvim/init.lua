---@diagnostic disable: undefined-field
vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
local config_dir = vim.fn.fnamemodify(vim.fn.expand('<sfile>'), ':h')
vim.opt.runtimepath:prepend(config_dir)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- Override markdown injections query BEFORE plugins load to avoid
pcall(vim.treesitter.query.set, "markdown", "injections", [[
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
]])
-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- Install lazy if not in path
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    priority = 1000,
  },

  { import = "plugins" },
}, lazy_config)


-- load theme
vim.schedule(function()
  -- NvChad's base46 build hook writes the per-integration cache files
  -- asynchronously during lazy's first run. Force the compile here so
  -- dofile() below always has files to source on a fresh install.
  pcall(function()
    require("base46").load_all_highlights()
  end)
  pcall(vim.cmd, "dofile " .. vim.g.base46_cache .. "defaults")
  pcall(vim.cmd, "dofile " .. vim.g.base46_cache .. "statusline")
end)

-- load options
require "options"

-- load custom autocmds
require "custom.utils.autocmd"

-- load usercmds
require "custom.utils.usercmd"

-- load mappings
vim.schedule(function()
  require "mappings"
end)

-- sign defines
vim.fn.sign_define("DapBreakpoint", { text = "󰙧", numhl = "DapBreakpoint", texthl = "DapBreakpoint" })
vim.fn.sign_define("DapLogPoint", { text = "", numhl = "DapLogPoint", texthl = "DapLogPoint" })
vim.fn.sign_define("DapStopped", { text = "", numhl = "DapStopped", texthl = "DapStopped" })
vim.fn.sign_define(
  "DapBreakpointRejected",
  { text = "", numhl = "DapBreakpointRejected", texthl = "DapBreakpointRejected" }
)
