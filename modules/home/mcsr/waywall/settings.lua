return {
	-- ==== LOOKS ====
	resolution = { 2560, 1600 },

	bg_col = "#000000ff",
	-- Colorkey recolor targets.
	text_col = "#FFFFFF",
	pie_chart_1 = "#EC6E4E", -- orange (block entities)
	pie_chart_2 = "#46CE66", -- green
	pie_chart_3 = "#E446C4", -- purple (entities)
	-- Dark wedge shades for native 3D look.
	pie_chart_1_dark = "#763727",
	pie_chart_2_dark = "#236733",
	pie_chart_3_dark = "#722362",
	ninbot_anchor = "bottomleft",
	ninbot_opacity = 1,

	-- Tiny black outline on E/C (waywall has no native border).
	number_border = {
		enabled = true,
		thickness = 1, -- 1 = 4-neighbor; 2 = full Moore neighborhood (heavier)
		color = "#000000",
	},

	-- ==== ALTERNATIVE RESOLUTIONS ====
	-- Thin widened so F3 entity lines clear CPU name.
	thin_res = { 400, 1520 },
	wide_res = { 2508, 400 },
	tall_res = { 384, 16384 },

	-- ==== MIRRORS ====
	-- https://github.com/arjuncgore/waywall_generic_config/blob/1440/init.lua
	-- tall_pie dst matches thin native pie (no shift on mode switch).
	-- Placement @ 2560x1600: C (1807,750), E (1807,838); size = (E.y-C.y)/9.
	-- e_chars / c_chars: glyphs after "E: "/"C: "; src_w = (3+chars)*6.
	e_count = {
		enabled = true,
		x = 1807,
		y = 838,
		c_y = 750,
		size = (838 - 750) / 9,
		e_chars = 3, -- "??/" (stops before trailing F3 comma)
		c_chars = 8, -- "???/????"
		colorkey = true,
		show_c = true,
	},
	-- tall_pie: dst = thin native pie box. Thin uses MC's native F3 pie.
	tall_pie = {
		enabled = true,
		x = 1150,
		y = 1161,
		w = 318,
		h = 168,
		colorkey = true,
		src = { x = 54, y = 15984, w = 318, h = 170 },
	},

	-- ==== MEASURING (boat eye) ====
	measuring = {
		src_w = 30,
		src_h = 1088,
		dst_w = 810,
		dst_h = 1088,
	},

	-- ==== SENS ====
	-- https://its-saanvi.github.io/linux-mcsr/minecraft/wayland/boat-eye.html
	sens = {
		normal = 16.0,
		eyezoom = 1.07935043,
	},

	-- ==== KEYBOARD ====
	-- xkb/mc (symbols) + remaps.lua (keycode remaps).
	xkb = {
		enabled = true,
		layout = "mc", -- ~/.config/xkb/symbols/mc
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

	-- Mode hotkeys only when in-world and unpaused (not inventory, pause menu, title, etc.).
	-- Requires State Output in the instance.
	ingame_only_modes = true,

	-- ==== MACROS ====
	-- https://tesselslate.github.io/waywall/03_lookup_tables.html#modifiers
	keys = {
		thin = "*-M",
		wide = "*-N",
		eyezoom = "*-grave",
		preemptive = "*-J",
		toggle_ninbot = "Page_Down",
		launch_paceman = "Shift-P",
	},
}
