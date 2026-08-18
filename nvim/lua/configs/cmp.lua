local M = {}
local list_contains = vim.list_contains or vim.tbl_contains

local function deprioritize_snippet(entry1, entry2)
  local types = require "cmp.types"

  if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
    return false
  end
  if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
    return true
  end
end

local function under(entry1, entry2)
  local _, entry1_under = entry1.completion_item.label:find "^_+"
  local _, entry2_under = entry2.completion_item.label:find "^_+"
  entry1_under = entry1_under or 0
  entry2_under = entry2_under or 0
  if entry1_under > entry2_under then
    return false
  elseif entry1_under < entry2_under then
    return true
  end
end

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local is_dap_buffer = function(bufnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr or 0 })
  if filetype == "dap-repl" or vim.startswith(filetype, "dapui_") then
    return true
  end
  return false
end

local disabled_buftypes = {
  "terminal",
  "prompt",
}

M.cmp = function()
  local cmp = require "cmp"
  local cmp_types = require "cmp.types"
  local luasnip = require "luasnip"
  local neogen = require "neogen"

  return {
    enabled = function()
      if vim.g.cmptoggle == false then
        return false
      end
      local disabled = false
      disabled = disabled or is_dap_buffer(0)
      disabled = disabled or list_contains(disabled_buftypes, vim.api.nvim_get_option_value("buftype", { buf = 0 }))
      disabled = disabled or vim.fn.reg_recording() ~= ""
      disabled = disabled or vim.fn.reg_executing() ~= ""
      disabled = disabled or require("cmp.config.context").in_treesitter_capture "comment"
      disabled = disabled or require("cmp.config.context").in_syntax_group "Comment"
      disabled = disabled or vim.api.nvim_get_mode().mode == "c"
      disabled = disabled or vim.b.rename
      return not disabled
    end,

    window = {
      completion = {
        border = "single",
        scrollbar = false,
        winhighlight = "Normal:CmpPmenu,CursorLine:CmpSel,Search:None,FloatBorder:CmpBorder",
      },
      documentation = {
        border = "single",
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
        scrollbar = false,
        winhighlight = "Normal:CmpDoc,FloatBorder:CmpDocBorder",
      },
    },

    view = {
      entries = { follow_cursor = true },
    },

    completion = {
      completeopt = "menu,menuone,noinsert,noselect",
      autocomplete = { cmp_types.cmp.TriggerEvent.TextChanged },
      keyword_length = 2,
    },

    mapping = {
      ["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item { behavior = cmp.SelectBehavior.Select }
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item { behavior = cmp.SelectBehavior.Select }
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<Left>"] = function(fallback)
        cmp.abort()
        fallback()
      end,

      ["<Right>"] = function(fallback)
        cmp.abort()
        fallback()
      end,

      ["<Tab>"] = cmp.mapping(function(fallback)
        if luasnip.expandable() then
          luasnip.expand()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif neogen.jumpable() then
          neogen.jump()
        elseif check_backspace() then
          fallback()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-tab>"] = cmp.mapping(function(fallback)
        if neogen.jumpable(true) then
          neogen.jump_prev()
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<CR>"] = cmp.mapping {
        i = function(fallback)
          if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm { select = true },
        c = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
      },

      ["<ESC>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
          cmp.close()
        else
          fallback()
        end
      end, { "i", "s" }),
    },

    performance = {
      debounce = 30,
      throttle = 20,
      async_budget = 0.8,
      max_view_entries = 10,
      fetching_timeout = 250,
    },

    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },

    sources = {
      { name = "nvim_lsp", keyword_length = 2, max_item_count = 10 },
      { name = "treesitter" },
      {
        name = "luasnip",
        max_item_count = 2,
        entry_filter = function()
          local ctx = require "cmp.config.context"
          local in_string = ctx.in_syntax_group "String" or ctx.in_treesitter_capture "string"
          local in_comment = ctx.in_syntax_group "Comment" or ctx.in_treesitter_capture "comment"
          return not in_string and not in_comment
        end,
      },
      { name = "lazydev" },
    },

    matching = {
      disallow_fuzzy_matching = true,
      disallow_fullfuzzy_matching = true,
      disallow_partial_fuzzy_matching = true,
      disallow_partial_matching = false,
      disallow_prefix_unmatching = true,
    },

    sorting = {
      priority_weight = 2,
      comparators = {
        deprioritize_snippet,
        cmp.config.compare.exact,
        cmp.config.compare.locality,
        cmp.config.compare.recently_used,
        under,
        cmp.config.compare.score,
        cmp.config.compare.kind,
        cmp.config.compare.length,
        cmp.config.compare.order,
        cmp.config.compare.sort_text,
      },
    },
  }
end

return M
