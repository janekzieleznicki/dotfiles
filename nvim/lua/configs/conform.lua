local conform = require "conform"

local function first(bufnr, ...)
  for index = 1, select("#", ...) do
    local formatter = select(index, ...)
    if conform.get_formatter_info(formatter, bufnr).available then
      return formatter
    end
  end
  return select(1, ...)
end

conform.setup {
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      lsp_format = "fallback",
      timeout_ms = 1000,
    }
  end,
  formatters = {
    kulala = {
      command = "kulala-fmt",
      args = { "$FILENAME" },
      stdin = false,
    },
  },
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    go = function(bufnr)
      return { first(bufnr, "goimports", "gofumpt") }
    end,
    rust = { "rustfmt", lsp_format = "fallback" },
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
    lua = { "stylua" },
    yaml = { "yamlfmt" },
    ["yaml.ansible"] = { "yamlfmt" },
    bash = { "shfmt" },
    sh = { "shfmt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    markdown = { "prettier" },
    http = { "kulala" },
  },
  notify_on_error = false,
}
