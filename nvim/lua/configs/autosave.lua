require("auto-save").setup {
  condition = function(buf)
    return vim.bo[buf].buftype == "" and vim.bo[buf].modifiable
  end,
  debounce_delay = 500,
  events = { "InsertLeave", "TextChanged" },
  silent = true,
}
