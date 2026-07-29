if vim.fn.executable("rust-analyzer") ~= 1 then
	return
end

local root_files = {
	"Cargo.toml",
	"rust-project.json",
	".git",
}

local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.fn.getcwd())

vim.lsp.start({
	name = "rust_analyzer",
	cmd = { "rust-analyzer" },
	root_dir = root,
	capabilities = require("user.lsp").make_client_capabilities(),
})
