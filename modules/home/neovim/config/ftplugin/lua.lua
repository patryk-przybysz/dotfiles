vim.bo.comments = ':---,:--'

if vim.fn.executable('lua-language-server') ~= 1 then
  return
end

local root_files = {
  '.luarc.json',
  '.luarc.jsonc',
  '.luacheckrc',
  '.stylua.toml',
  'stylua.toml',
  '.git',
}

local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.fn.getcwd())

vim.lsp.start {
  name = 'lua_ls',
  cmd = { 'lua-language-server' },
  root_dir = root,
  capabilities = require('user.lsp').make_client_capabilities(),
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
