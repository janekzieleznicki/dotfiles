-- 1. Podpięcie ścieżki do mini.test
local data_dir = vim.fn.stdpath("data")
local mini_path = data_dir .. "/lazy/mini.test"
if vim.fn.isdirectory(mini_path) == 0 then
  mini_path = data_dir .. "/lazy/mini.nvim"
end

vim.opt.rtp:prepend(mini_path)

-- 2. Weryfikacja obecności modułu mini.test
local ok, MiniTest = pcall(require, "mini.test")
if not ok then
  print("CRITICAL: module 'mini.test' not found at " .. mini_path)
  vim.cmd("cquit! 1")
end

-- 3. Konfiguracja raportowania
MiniTest.setup({
  execute = { reporter = MiniTest.gen_reporter.stdout({ group_depth = 2 }) },
})

-- 4. Ustalenie ścieżki do pliku testów
local test_file = "nvim/test/test_e2e.lua"
if vim.fn.filereadable(test_file) == 0 then
  test_file = "test/test_e2e.lua"
end

-- 5. Natywne wykonanie pliku przez wbudowaną funkcję run_file
local test_results = MiniTest.run_file(test_file)

-- 6. Bezpieczna obsługa zakończenia z kodem błędu
if not test_results or test_results.has_case_failure then
  vim.cmd("cquit! 1")
else
  vim.cmd("qa!")
end