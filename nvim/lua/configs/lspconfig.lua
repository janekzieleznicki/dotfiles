-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local servers = {
  "htmx",
  "svelte",
  "astro",
  "vuels",
  "jsonls",
  "yamlls",
  "marksman",
  "sqlls",
  "solidity",
  "gdscript",
  "pylsp",
  "clangd",
  "cmake",
  "gopls",
  "denols",
  "nginx_language_server",
  "arduino_language_server",
  "docker_compose_language_service",
  "lua_ls",
  "cssls",
  "tsserver",
  "html",
  "tailwindcss",
}

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
}

lspconfig.cssls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "css", "scss", "less", "html" },
}

lspconfig.html.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  init_options = {
    configurationSection = { "html", "css", "javascript" },
    embeddedLanguages = {
      css = true,
      javascript = true,
    },
    provideFormatter = true,
  },
}

lspconfig.tailwindcss.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = {
    "aspnetcorerazor",
    "astro",
    "astro-markdown",
    "blade",
    "clojure",
    "django-html",
    "htmldjango",
    "edge",
    "eelixir",
    "elixir",
    "ejs",
    "erb",
    "eruby",
    "gohtml",
    "gohtmltmpl",
    "haml",
    "handlebars",
    "hbs",
    "html",
    "html-eex",
    "heex",
    "jade",
    "leaf",
    "liquid",
    "markdown",
    "mdx",
    "mustache",
    "njk",
    "nunjucks",
    "php",
    "razor",
    "slim",
    "twig",
    "css",
    "less",
    "postcss",
    "sass",
    "scss",
    "stylus",
    "sugarss",
    "javascript",
    "javascriptreact",
    "reason",
    "rescript",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
    "rust",
  },
  init_options = {
    userLanguages = {
      rust = "html",
    },
  },
}

-- local overrides = require("configs.overrides")
-- -- overriding default lspconfig
-- for key, value in pairs(overrides.lsp) do

--   local opt = {
--     on_attach = on_attach,
--     capabilities = capabilities,
--   }

--   if value.filetypes then
--     opt.filetypes = value.filetypes
--   end

--   if value.init_options then
--     opt.init_options = value.init_options
--   end

--   config[key].setup(opt)
-- end
