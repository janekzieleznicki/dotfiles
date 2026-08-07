return {
  "mrcjkb/rustaceanvim",
  version = "^6",
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd.RustLsp "codeAction"
          end, { buffer = bufnr, silent = true })
          vim.keymap.set("n", "K", function()
            vim.cmd.RustLsp { "hover", "actions" }
          end, { buffer = bufnr, silent = true })
        end,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            check = { command = "clippy" },
            inlayHints = {
              bindingModeHints = { enable = true },
              closureReturnTypeHints = { enable = "with_block" },
            },
          },
        },
      },
    }
  end,
}
