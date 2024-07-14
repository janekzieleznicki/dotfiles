return {  
    {
  	"nvim-tree/nvim-tree.lua",
  	opts = {
    -- use icon in git status but doesnt hide ignore from file tree
  git = {
    enable = true,
    ignore = false
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}
    }
}