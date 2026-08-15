-- nvim/test/test_e2e.lua
local MiniTest = require('mini.test')
local child = MiniTest.new_child_neovim()

local current_file = debug.getinfo(1, "S").source:sub(2)
local test_dir = vim.fn.fnamemodify(current_file, ":p:h")
local samples_dir = test_dir .. "/samples/"
local nvim_dir = test_dir .. "/.."

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      child.start({}, {
        command = { vim.v.progpath, "--headless", "-u", test_dir .. "/../init.lua" }
      })
      -- Check if lazy is loaded right after start
      local lazy_loaded = child.lua_get("package.loaded.lazy")
      print("DEBUG: lazy.loaded right after start = " .. (lazy_loaded and "table" or "nil"))
      -- Set runtimepath to include our nvim directory
      child.cmd('lua vim.o.runtimepath = vim.o.runtimepath .. "," .. "' .. nvim_dir .. '"')
      -- Also add data path to runtimepath
      child.cmd('lua vim.o.runtimepath = vim.o.runtimepath .. "," .. vim.fn.stdpath("data")')
      -- Check if lazy plugin exists in runtimepath
      child.cmd('lua print("lazy plugin path: " .. vim.fn.globpath(vim.o.runtimepath, "lazy/lazy.nvim/init.lua"))')
      -- Check if the lazy init file exists directly
      child.cmd('lua print("lazy init exists: " .. tostring(vim.fn.filereadable("' .. nvim_dir .. '/lazy/lazy.nvim/init.lua")))')
      -- Check data path
      child.cmd('lua print("data path: " .. vim.fn.stdpath("data"))')
      -- Check if lazy plugin exists in data path
      child.cmd('lua print("lazy plugin in data: " .. vim.fn.globpath(vim.fn.stdpath("data"), "lazy/lazy.nvim/init.lua"))')
      -- List data path contents
      child.cmd('lua print("data path contents: " .. vim.inspect(vim.fn.readdir(vim.fn.stdpath("data"))))')
      -- List lazy directory contents in data path
      child.cmd('lua print("lazy directory contents: " .. vim.inspect(vim.fn.readdir(vim.fn.stdpath("data") .. "/lazy")))')
      -- List lazy.nvim directory contents in data path
      child.cmd('lua print("lazy.nvim directory contents: " .. vim.inspect(vim.fn.readdir(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")))')
      -- List lazy.nvim lua directory contents in data path
      child.cmd('lua print("lua directory contents: " .. vim.inspect(vim.fn.readdir(vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua")))')
      -- List lazy.nvim lua lazy directory contents in data path
      child.cmd('lua print("lua/lazy directory contents: " .. vim.inspect(vim.fn.readdir(vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy")))')
      -- Add lazy.nvim lua directory to package.path for both file and directory modules
      child.cmd('lua package.path = package.path .. ";' .. vim.fn.stdpath("data") .. '/lazy/lazy.nvim/lua/?.lua;' .. vim.fn.stdpath("data") .. '/lazy/lazy.nvim/lua/?/init.lua"')
      -- Check package.path
      child.cmd('lua print("package.path: " .. package.path)')
      -- Print runtimepath to confirm
      child.cmd('lua print("runtimepath: " .. vim.inspect(vim.o.runtimepath))')
      local rt_msg = child.api.nvim_exec2("messages", { output = true }).output
      print("DEBUG: runtimepath msg: " .. rt_msg)
    end,
    post_case = function()
      child.stop()
    end,
  },
})

------------------------------------------------------------------------
-- Test 1: Symulacja pisания и выполнение скrótu klawiszowego
------------------------------------------------------------------------
T['Klawiatura i Edycja'] = function()
  child.type_keys('i', 'local x = 42', '<Esc>')

  local lines = child.api.nvim_buf_get_lines(0, 0, -1, false)
  MiniTest.expect.equality(lines[1], 'local x = 42')

  child.type_keys(':set relativenumber!', '<CR>')
  local relnum = child.lua_get('vim.o.relativenumber')
  MiniTest.expect.equality(relnum, true)
end

------------------------------------------------------------------------
-- Test 2: Popправность действия customowych команд
------------------------------------------------------------------------
T['Wykonanie Komend'] = function()
  local lazy_loaded_val = child.lua_get('package.loaded.lazy')
  print("DEBUG: lazy.loaded value = " .. (lazy_loaded_val and "table" or "nil"))
  if lazy_loaded_val == nil then
    print("DEBUG: lazy module not loaded, checking package.loaded keys")
    local keys = child.lua_get('vim.inspect(vim.tbl_keys(package.loaded))')
    print("DEBUG: package.loaded keys = " .. keys)
    MiniTest.expect.fail("Lazy module not loaded")
  else
    -- Get the value of package.loaded.lazy in the child
    local lazy_loaded_val_child = child.lua_get("package.loaded.lazy")
    print("DEBUG: lazy.loaded value in child = " .. (lazy_loaded_val_child and "table" or "nil"))
    print("DEBUG: lazy.loaded value in child type = " .. type(lazy_loaded_val_child))
    -- Get the keys of package.loaded
    local keys = child.lua_get("vim.inspect(vim.tbl_keys(package.loaded))")
    print("DEBUG: package.loaded keys = " .. keys)
    if lazy_loaded_val_child == nil then
      print("DEBUG: lazy module not loaded in child")
      MiniTest.expect.fail("Lazy module not loaded in child")
    else
      -- We have the lazy module table in lazy_loaded_val_child
      print("DEBUG: Trying to inspect lazy module show field via require")
      child.cmd('lua local lazy = require("lazy"); print(tostring(lazy.show))')
      local msgs = child.api.nvim_exec2("messages", { output = true }).output
      print("DEBUG: Messages after inspect show: " .. msgs)
      print("DEBUG: Trying to show via lua command")
      child.cmd('lua local old_show = require("lazy").show; require("lazy").show = function() print("Lazy show called"); return old_show() end; local win_count_before = #vim.api.nvim_list_wins(); local ok, err = pcall(function() require("lazy").setup({}); require("lazy").show() end); _G.test_ok = ok')
      print("DEBUG: After lazy command")
      local bufs = child.lua_get("vim.api.nvim_list_bufs()")
      print("DEBUG: number of buffers: " .. (bufs and #bufs or "nil"))
      local msgs = child.api.nvim_exec2("messages", { output = true }).output
      print("DEBUG: Messages after Lazy: " .. msgs)
      local test_ok = child.lua_get('_G.test_ok')
      MiniTest.expect.equality(test_ok, true)
    end
  end
end

------------------------------------------------------------------------
-- Test 3: Podgląd TUI / UI Render
------------------------------------------------------------------------
T['Podgląd TUI / UI Render'] = function()
  local sample_file = samples_dir .. "sample.lua"
  
  child.cmd('edit ' .. vim.fn.fnameescape(sample_file))

  local ok_ft = vim.wait(2000, function()
    return child.lua_get("vim.bo.filetype") == "lua"
  end, 50)
  MiniTest.expect.equality(ok_ft, true)

  local bufname = child.api.nvim_buf_get_name(0)
  local has_correct_name = bufname:match("sample%.lua") ~= nil
  
  MiniTest.expect.equality(has_correct_name, true)
end

return T