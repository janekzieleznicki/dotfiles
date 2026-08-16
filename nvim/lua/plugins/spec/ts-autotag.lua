local status_ok, auto_tag = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  auto_tag = nil
end
return {
  "windwp/nvim-ts-autotag",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    if auto_tag then
      ---@diagnostic disable-next-line
      auto_tag.setup {
        autotag = {
          enable = true,
        },
      }
    end
  end,
}