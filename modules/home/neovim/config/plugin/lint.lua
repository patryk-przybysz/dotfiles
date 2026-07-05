local lint = require("lint")

local efm = "stdin:%l:%c %m,stdin:%l %m"
lint.linters.markdownlint = {
	cmd = "markdownlint-cli2",
	stdin = true,
	args = { "-" },
	ignore_exitcode = true,
	stream = "stderr",
	parser = require("lint.parser").from_errorformat(efm, {
		source = "markdownlint",
		severity = vim.diagnostic.severity.WARN,
	}),
}

lint.linters_by_ft = {
	markdown = { "markdownlint" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		if vim.bo.modifiable then
			lint.try_lint()
		end
	end,
})
