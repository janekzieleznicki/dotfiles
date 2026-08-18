require("nvchad.configs.lspconfig").defaults()

local defaults = require "nvchad.configs.lspconfig"
local capabilities = vim.tbl_deep_extend("force", defaults.capabilities, {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
})

local function on_attach(client, bufnr)
  defaults.on_attach(client, bufnr)

  if client:supports_method "textDocument/documentHighlight" then
    local group = vim.api.nvim_create_augroup("lsp_document_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
      buffer = bufnr,
      group = group,
      callback = vim.lsp.buf.clear_references,
    })
  end

  if client:supports_method "textDocument/documentSymbol" then
    local ok, navic = pcall(require, "nvim-navic")
    if ok then
      navic.attach(client, bufnr)
    end
  end

  local ok, workspace_diagnostics = pcall(require, "workspace-diagnostics")
  if ok then
    workspace_diagnostics.populate_workspace_diagnostics(client, bufnr)
  end
end

local function config(server, settings)
  vim.lsp.config(
    server,
    vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      on_attach = on_attach,
      on_init = defaults.on_init,
    }, settings or {})
  )
end

local servers = {
  "ansiblels",
  "bashls",
  "clangd",
  "dockerls",
  "gopls",
  "jsonls",
  "lua_ls",
  "marksman",
  "terraformls",
  "yamlls",
}

require("mason-lspconfig").setup {
  ensure_installed = servers,
  automatic_enable = false,
}

config("ansiblels", {
  settings = {
    ansible = {
      ansible = { path = "ansible" },
      python = { interpreterPath = "python3" },
      validation = {
        enabled = true,
        lint = {
          enabled = true,
          path = "ansible-lint",
        },
      },
    },
  },
})

config "bashls"

config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
  },
  capabilities = vim.tbl_deep_extend("force", capabilities, {
    offsetEncoding = { "utf-16" },
  }),
})

config "dockerls"

config("gopls", {
  filetypes = { "go", "gomod", "gowork", "gosum" },
  settings = {
    gopls = {
      completeUnimported = true,
      directoryFilters = { "-.git", "-.idea", "-.vscode", "-node_modules" },
      gofumpt = true,
      staticcheck = true,
      usePlaceholders = true,
      vulncheck = "Imports",
      analyses = {
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

config("jsonls", {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
})

config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      hint = { enable = true },
      runtime = { version = "LuaJIT" },
      telemetry = { enable = false },
      workspace = { checkThirdParty = false },
    },
  },
})

config "marksman"
config "terraformls"

config("yamlls", {
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
      validate = true,
    },
  },
})

vim.lsp.enable(servers)

local severity = vim.diagnostic.severity
vim.diagnostic.config {
  float = {
    border = "rounded",
    source = "if_many",
  },
  severity_sort = true,
  signs = {
    text = {
      [severity.ERROR] = "󰅙",
      [severity.WARN] = "",
      [severity.INFO] = "󰋼",
      [severity.HINT] = "󰌵",
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_lines = false,
  virtual_text = {
    prefix = "■",
    spacing = 2,
  },
}

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  end,
})
