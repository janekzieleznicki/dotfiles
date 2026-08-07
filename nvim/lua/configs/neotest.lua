local namespace = vim.api.nvim_create_namespace "neotest"

vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      return diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
    end,
  },
}, namespace)

require("neotest").setup {
  adapters = {
    require "neotest-go" {
      args = { "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" },
      experimental = { test_table = true },
    },
    require "rustaceanvim.neotest",
  },
  diagnostic = { enabled = false },
  floating = {
    border = "rounded",
    max_height = 0.6,
    max_width = 0.6,
  },
  output = {
    enabled = true,
    open_on_run = true,
  },
  quickfix = {
    open = function()
      vim.cmd "Trouble qflist toggle"
    end,
  },
  status = {
    enabled = true,
    signs = true,
    virtual_text = false,
  },
  summary = {
    enabled = true,
    expand_errors = true,
    follow = true,
  },
}
