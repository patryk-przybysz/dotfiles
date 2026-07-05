if vim.fn.executable("nil") ~= 1 then
	return
end

local root_files = {
	"flake.nix",
	"default.nix",
	"shell.nix",
	".git",
}

local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.fn.getcwd())

vim.lsp.start({
	name = "nil_ls",
	cmd = { "nil" },
	root_dir = root,
	capabilities = require("user.lsp").make_client_capabilities(),
})
