if vim.fn.executable("typescript-language-server") ~= 1 then
	return
end

local root_files = {
	"package.json",
	"tsconfig.json",
	"jsconfig.json",
	".git",
}

local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.fn.getcwd())

vim.lsp.start({
	name = "ts_ls",
	cmd = { "typescript-language-server", "--stdio" },
	root_dir = root,
	capabilities = require("user.lsp").make_client_capabilities(),
})
