return {

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
    "arduino",
    "astro",
    "cmake",
    "cpp",
    "csv",
    "gdscript",
    "go",
    "htmldjango",
    "json",
    "python",
    "rust",
    "solidity",
    "sql",
    "svelte",
    "toml",
    "vue",
    "xml",
    "yaml",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
  autotag = {
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
    filetypes = {
    'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx', 'rescript',
    'xml',
    'php',
    'markdown',
    'astro', 'glimmer', 'handlebars', 'hbs','rust'}
  }
  	},
  },
}