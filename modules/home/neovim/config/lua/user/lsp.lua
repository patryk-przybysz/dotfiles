local M = {}

---@return lsp.ClientCapabilities
function M.make_client_capabilities()
  return require('blink.cmp').get_lsp_capabilities()
end

return M
