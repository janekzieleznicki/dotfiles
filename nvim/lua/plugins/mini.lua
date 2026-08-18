return {
  {
    "echasnovski/mini.test",
    version = false,
    lazy = not (vim.env.TEST_MODE == "1" or vim.env.CI),
    cmd = "MiniTest",
  },
}
