local function merge(...)
	local out = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		if t then
			for k, v in pairs(t) do
				out[k] = v
			end
		end
	end
	return out
end

local palette = {
	bg_col = "#000000ff",
	text_col = "#FFFFFF",
	pie_chart_1 = "#EC6E4E", -- orange (block entities)
	pie_chart_2 = "#46CE66", -- green (unspecified)
	pie_chart_3 = "#E446C4", -- purple (entities)
	pie_chart_1_dark = "#763727",
	pie_chart_2_dark = "#236733",
	pie_chart_3_dark = "#722362",
	ninbot_anchor = "bottomleft",
	ninbot_opacity = 1,
	number_border = {
		enabled = true,
		thickness = 1,
		color = "#000000",
	},
}

local resolutions = {
	fullscreen = { 2560, 1600 },
	thin = { 330, 1520 },
	wide = { 2508, 400 },
	tall = { 384, 16384 },
}

local percent_thin_src = { x = 237, y = 1300, w = 12, h = 7 }
local percent_tall_src = { x = 291, y = 16164, w = 12, h = 7 }

local mirrors = {
	{
		name = "e_counter",
		items = {
			{
				input = "#DDDDDD",
				output = palette.text_col,
				modes = { "thin", "eyezoom", "preemptive" },
				src = { x = 1, y = 37, w = 36, h = 9 },
				dst = { x = 1807, y = 838, w = 352, h = 88 },
			},
		},
	},
	{
		name = "c_counter",
		items = {
			{
				input = "#DDDDDD",
				output = palette.text_col,
				modes = { "thin", "eyezoom", "preemptive" },
				src = { x = 1, y = 28, w = 66, h = 9 },
				dst = { x = 1807, y = 750, w = 5808 / 9, h = 88 },
			},
		},
	},
	{
		name = "tall_pie",
		defaults = {
			use_border = false,
			modes = { "preemptive" },
			src = { x = 53, y = 15983, w = 320, h = 170 },
			dst = { x = 1114, y = 1159, w = 320, h = 170 },
		},
		items = {
			{ input = "#EC6E4E", output = palette.pie_chart_1 },
			{ input = "#763727", output = palette.pie_chart_1_dark },
			{ input = "#46CE66", output = palette.pie_chart_2 },
			{ input = "#236733", output = palette.pie_chart_2_dark },
			{ input = "#E446C4", output = palette.pie_chart_3 },
			{ input = "#722362", output = palette.pie_chart_3_dark },
		},
	},
	{
		name = "percent_be",
		stable = { rows = 4, row_step = 8 },
		defaults = {
			dst = { x = 1166, y = 1201, w = 60, h = 35 },
			input = "#E96D4D",
			output = palette.pie_chart_1,
		},
		items = {
			{ modes = { "thin" }, src = percent_thin_src },
			{ modes = { "preemptive" }, src = percent_tall_src },
		},
	},
	{
		name = "percent_un",
		stable = { rows = 4, row_step = 8 },
		defaults = {
			dst = { x = 1166, y = 1244, w = 60, h = 35 },
			input = "#45CB65",
			output = palette.pie_chart_2,
		},
		items = {
			{ modes = { "thin" }, src = percent_thin_src },
			{ modes = { "preemptive" }, src = percent_tall_src },
		},
	},
	{
		name = "mapless",
		stable = { rows = 4, row_step = 8 },
		defaults = { input = "#E96D4D", output = palette.text_col },
		items = {
			{
				modes = { "thin" },
				src = { x = 288, y = 1300, w = 25, h = 7 },
				dst = { x = 1280, y = 1235, w = 125, h = 35 },
			},
			{
				modes = { "fullscreen" },
				src = { x = 2518, y = 1380, w = 25, h = 7 },
				dst = { x = 2395, y = 1290, w = 125, h = 35 },
			},
		},
	},
	{
		name = "glowdar",
		stable = { rows = 4, row_step = 8 },
		items = {
			{
				input = "#4DE1CA",
				output = "#4DE1CA",
				modes = { "fullscreen" },
				src = { x = 2468, y = 1380, w = 25, h = 7 },
				dst = { x = 2395, y = 1290, w = 125, h = 35 },
			},
		},
	},
}

local measuring = {
	src_w = 30,
	src_h = 1088,
	dst_w = 810,
	dst_h = 1088,
}

local sens = {
	normal = 16.0,
	eyezoom = 1.07935043,
}

local keyboard = {
	xkb = {
		enabled = true,
		layout = "mc",
		variant = "basic",
		rules = nil,
		options = "caps:none",
		chat_layout = "pl",
		repeat_rate = 60,
		repeat_delay = 180,
	},
	chat_mode = {
		toggle_key = "BACKSLASH",
		text = "chat mode",
		x = 100,
		y = 100,
		size = 2,
		color = palette.text_col,
	},
	ingame_only_modes = true,
	keys = {
		thin = "*-M",
		wide = "*-N",
		eyezoom = "*-grave",
		preemptive = "*-J",
		toggle_ninbot = "Page_Down",
		launch_paceman = "Shift-P",
	},
}

return merge(palette, resolutions, {
	mirrors = mirrors,
	measuring = measuring,
	sens = sens,
}, keyboard)
