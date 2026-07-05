require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()
require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})

local statusline = require("mini.statusline")
statusline.setup({ use_icons = vim.g.have_nerd_font })
statusline.section_location = function()
	return "%2l:%-2v"
end

require("mini.files").setup()

vim.keymap.set("n", "<leader>e", function()
	require("mini.files").open()
end, { desc = "Open file [E]xplorer" })

vim.keymap.set("n", "-", function()
	require("mini.files").open(vim.api.nvim_buf_get_name(0))
end, { desc = "Open parent directory" })
