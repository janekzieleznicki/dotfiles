---@class ChadrcConfig
local M = {}

local core = require "custom.utils.core"
local highlights = require "custom.highlights"

M.ui = {
  statusline = core.statusline,
  tabufline = core.tabufline,
}

M.nvdash = core.nvdash

M.base46 = {
  theme = "catppuccin-frappe",
  integrations = {
    "blankline",
    "cmp",
    "defaults",
    "devicons",
    "git",
    "lsp",
    "markview",
    "mason",
    "nvcheatsheet",
    "nvimtree",
    "statusline",
    "syntax",
    "tbline",
    "telescope",
    "whichkey",
    "dap",
    "hop",
    "treesitter",
    "rainbowdelimiters",
    "diffview",
    "todo",
    "trouble",
    "notify",
  },
  hl_override = highlights.override,
  hl_add = highlights.add,
}

return M