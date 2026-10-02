local M = {}

function M.start()
	if vim.fn.executable("clangd") ~= 1 then
		return
	end

	local root_files = {
		"compile_commands.json",
		"compile_flags.txt",
		".clangd",
		"CMakeLists.txt",
		"Makefile",
		".git",
	}

	local root = vim.fs.dirname(vim.fs.find(root_files, { upward = true })[1] or vim.fn.getcwd())

	vim.lsp.start({
		name = "clangd",
		cmd = { "clangd" },
		root_dir = root,
		capabilities = require("user.lsp").make_client_capabilities(),
	})
end

return M
