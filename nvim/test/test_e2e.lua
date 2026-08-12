-- nvim/test/test_e2e.lua
local MiniTest = require('mini.test')
local child = MiniTest.new_child_neovim()

local current_file = debug.getinfo(1, "S").source:sub(2)
local test_dir = vim.fn.fnamemodify(current_file, ":p:h")
local samples_dir = test_dir .. "/samples/"

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      -- Przekazujemy +Lazy! sync na starcie, aby wtyczki zamknęły proces pobierania
      child.start({
        '+Lazy! sync',
      }, {
        command = { vim.v.progpath, '--embed', '--headless', '-n' }
      })

      -- Zwiększamy czas oczekiwania do 15 sekund na wypadek wolniejszego I/O w kontenerze
      local ok = vim.wait(15000, function()
        return child.lua_get("vim.fn.exists(':Lazy')") == 2
      end, 100)

      if not ok then
        local msgs = child.api.nvim_exec2("messages", { output = true }).output
        error("Timeout: Neovim nie załadował komendy :Lazy.\n--- LOGI Z NEOVIMA ---\n" .. msgs)
      end
    end,

    post_case = function()
      child.stop()
    end,
  },
})

------------------------------------------------------------------------
-- Test 1: Symulacja pisania i wykonanie skrótu klawiszowego
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
-- Test 2: Poprawność działania customowych komend
------------------------------------------------------------------------
T['Wykonanie Komend'] = function()
  child.cmd('Lazy')

  local ok = vim.wait(3000, function()
    return child.lua_get("vim.bo.filetype") == "lazy"
  end, 50)
  
  MiniTest.expect.equality(ok, true)
end

------------------------------------------------------------------------
-- Test 3: Weryfikacja działania wtyczek na konkretnych plikach
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