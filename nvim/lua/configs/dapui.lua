local dap = require "dap"
local dapui = require "dapui"
local dap_virtual_text = require "nvim-dap-virtual-text"

dapui.setup(require("custom.utils.core").dapui)

local function open_ui()
  local ok, api = pcall(require, "nvim-tree.api")
  if ok then
    api.tree.close()
  end
  dapui.open()
  dap_virtual_text.refresh()
end

local function close_ui()
  dapui.close()
  dap_virtual_text.refresh()
end

dap.listeners.after.event_initialized["dapui_config"] = open_ui
dap.listeners.before.event_terminated["dapui_config"] = close_ui
dap.listeners.before.event_exited["dapui_config"] = close_ui
dap.listeners.before.disconnect["dapui_config"] = close_ui
