local ok, lint = pcall(require, "lint")
if not ok then
  return
end

lint.linters_by_ft = {
  go = { "golangcilint" },
  gomod = { "golangcilint" },
  gowork = { "golangcilint" },
  terraform = { "tflint" },
  ["terraform-vars"] = { "tflint" },
  ["yaml.ansible"] = { "ansible_lint" },
  yaml = { "yamllint" },
  bash = { "shellcheck" },
  sh = { "shellcheck" },
  lua = { "luacheck" },
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
}

local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = group,
  callback = function()
    lint.try_lint()
  end,
})
