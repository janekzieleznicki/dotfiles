return {
  {
  	"williamboman/mason.nvim",
  	opts = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",


    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "htmx-lsp", --experimental new lsp
    "typescript-language-server",
    "svelte-language-server",
    "astro-language-server",
    "vetur-vls", --vue lsp
    "tailwindcss-language-server",
    "deno",
    "prettier",
    -- for djinja or django templating
    "djlint",
    "python-lsp-server",

    --data/content general
    "json-lsp",
    "markdownlint",
    "marksman",
    "sqlls", --golang version of sqlls
    "sqlfmt",
    "yaml-language-server",
    "yamlfmt",
    "yamllint",

    --rust
    "rust-analyzer",
    "taplo", --for toml lsp

    --solidity
    "solidity",

    -- c/cpp stuff
    "clangd",
    "clang-format",
    "cmake-language-server",

    --go
    "gopls",
    "goimports",

    --godot
    "gdtoolkit",

    --proxy or container
    "docker-compose-language-service",
    "dockerfile-language-server",
    "nginx-language-server",

    --arduino
    "arduino-language-server",
  },
  	},
  },
}