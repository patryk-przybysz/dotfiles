return {
	-- ==== LOOKS ====
	resolution = { 2560, 1600 },

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

	-- ==== ALTERNATIVE RESOLUTIONS ====
	thin_res = { 330, 1520 },
	wide_res = { 2508, 400 },
	tall_res = { 384, 16384 },

	-- ==== MIRRORS ====
	-- All src/dst are absolute top-left rectangles.
	-- src = game framebuffer; dst = monitor.

	e_count = {
		enabled = true,
		x = 1807,
		y = 838,
		c_y = 750,
		size = (838 - 750) / 9,
		e_chars = 3,
		c_chars = 8,
		colorkey = true,
		show_c = true,
	},

	tall_pie = {
		enabled = true,
		colorkey = true,
		src = { x = 53, y = 15983, w = 320, h = 170 },
		dst = { x = 1114, y = 1159, w = 320, h = 170 },
	},

	percent = {
		enabled = true,
		match_text = false,
		rows = 4,
		row_step = 8,
		thin_src = { x = 237, y = 1300, w = 12, h = 7 },
		tall_src = { x = 291, y = 16164, w = 12, h = 7 },
		blockentities = { x = 1166, y = 1201, w = 60, h = 35 },
		unspecified = { x = 1166, y = 1244, w = 60, h = 35 },
	},

	mapless = {
		enabled = true,
		rows = 4,
		row_step = 8,
		output = "#FFFFFF",
		normal = {
			src = { x = 2518, y = 1380, w = 25, h = 7 },
			dst = { x = 2395, y = 1290, w = 125, h = 35 },
		},
		thin = {
			src = { x = 288, y = 1300, w = 25, h = 7 },
			dst = { x = 1280, y = 1235, w = 125, h = 35 },
		},
	},

	glowdar = {
		enabled = true,
		colorkey = true,
		rows = 4,
		row_step = 8,
		input_colors = { "#4DE1CA", "#4EE4CC" },
		output = "#4DE1CA",
		src = { x = 2468, y = 1380, w = 25, h = 7 },
		dst = { x = 2395, y = 1290, w = 125, h = 35 },
	},

	-- ==== MEASURING (boat eye) ====
	measuring = {
		src_w = 30,
		src_h = 1088,
		dst_w = 810,
		dst_h = 1088,
	},

	-- ==== SENS ====
	sens = {
		normal = 16.0,
		eyezoom = 1.07935043,
	},

	-- ==== KEYBOARD ====
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
		color = "#FFFFFF",
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
