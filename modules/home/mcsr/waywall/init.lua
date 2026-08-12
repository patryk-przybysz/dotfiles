-- Entry: mcsr-nixos bakes programs/files into this chunk only.
-- https://git.uku3lig.net/uku/mcsr-nixos/src/branch/main/doc/waywall.md
-- https://github.com/arjuncgore/waywall_generic_config

local waywall = require("waywall")
local helpers = require("waywall.helpers")
local Scene = require("waywork.scene")
local Modes = require("waywork.modes")
local Keys = require("waywork.keys")
local Processes = require("waywork.processes")

local remaps = require("remaps")
local cfg = require("settings")

cfg.ninjabrain_bot = programs.ninjabrain_bot
cfg.paceman_tracker = programs.paceman_tracker
cfg.eye_overlay = files.eye_overlay

local ensure_ninjabrain = Processes.ensure_application(waywall, cfg.ninjabrain_bot)("ninjabrain.*\\.jar")
local ensure_paceman =
	Processes.ensure_application(waywall, cfg.paceman_tracker, { "--nogui" })("paceman-tracker.*\\.jar")

local display = { w = cfg.resolution[1], h = cfg.resolution[2] }
local thin_res = { w = cfg.thin_res[1], h = cfg.thin_res[2] }
local wide_res = { w = cfg.wide_res[1], h = cfg.wide_res[2] }
local tall_res = { w = cfg.tall_res[1], h = cfg.tall_res[2] }

local normal_sens = cfg.sens.normal
local eyezoom_sens = cfg.sens.eyezoom
local xkb = cfg.xkb

local config = {
	input = {
		layout = (xkb.enabled and xkb.layout) or nil,
		rules = (xkb.enabled and xkb.rules) or nil,
		variant = (xkb.enabled and xkb.variant) or nil,
		options = (xkb.enabled and xkb.options) or nil,
		repeat_rate = xkb.repeat_rate,
		repeat_delay = xkb.repeat_delay,
		remaps = remaps.remapped_kb or {},
		sensitivity = normal_sens,
		confine_pointer = false,
	},
	theme = {
		background = cfg.bg_col,
		ninb_anchor = cfg.ninbot_anchor,
		ninb_opacity = cfg.ninbot_opacity,
	},
	window = {
		fullscreen_width = display.w,
		fullscreen_height = display.h,
	},
}

local scene = Scene.SceneManager.new(waywall)

-- https://tesselslate.github.io/waywall/02_waywall_mirror.html
local pie_colors = {
	{ input = "#EC6E4E", output = cfg.pie_chart_1 },
	{ input = "#763727", output = cfg.pie_chart_1_dark or "#763727" },
	{ input = "#46CE66", output = cfg.pie_chart_2 },
	{ input = "#236733", output = cfg.pie_chart_2_dark or "#236733" },
	{ input = "#CC6C46", output = cfg.pie_chart_2 },
	{ input = "#464C46", output = cfg.pie_chart_2 },
	{ input = "#E446C4", output = cfg.pie_chart_3 },
	{ input = "#722362", output = cfg.pie_chart_3_dark or "#722362" },
}

-- Fake outline: offset colorkey mirrors under the glyph.
local border_cfg = cfg.number_border or { enabled = false }
local function border_offsets(thickness)
	local t = thickness or 1
	local offs = {}
	for dx = -t, t do
		for dy = -t, t do
			if dx ~= 0 or dy ~= 0 then
				offs[#offs + 1] = { dx, dy }
			end
		end
	end
	return offs
end

-- Register one or more colorkey mirrors; optional black outline via shifted copies.
local function register_keyed(name_prefix, src, dst, groups, keys, depth, use_border)
	local d = depth or 2
	if use_border ~= false and border_cfg.enabled and keys then
		local bcol = border_cfg.color or "#000000"
		local offs = border_offsets(border_cfg.thickness or 1)
		for ki, ck in ipairs(keys) do
			for oi, off in ipairs(offs) do
				scene:register(name_prefix .. "_b" .. ki .. "_" .. oi, {
					kind = "mirror",
					options = {
						src = src,
						dst = {
							x = dst.x + off[1],
							y = dst.y + off[2],
							w = dst.w,
							h = dst.h,
						},
						depth = d,
						color_key = { input = ck.input, output = bcol },
					},
					groups = groups,
				})
			end
		end
		d = d + 1
	end
	if keys then
		for i, ck in ipairs(keys) do
			scene:register(name_prefix .. "_" .. i, {
				kind = "mirror",
				options = { src = src, dst = dst, depth = d, color_key = ck },
				groups = groups,
			})
		end
	else
		scene:register(name_prefix .. "_all", {
			kind = "mirror",
			options = { src = src, dst = dst, depth = d },
			groups = groups,
		})
	end
end

-- E / C: separate F3-line mirrors.
local F3_CHAR_W, F3_LABEL, F3_LINE_H = 6, 3, 9
local ec = cfg.e_count
local ec_size = ec.size
local ec_keys = ec.colorkey and { { input = "#DDDDDD", output = cfg.text_col } } or nil

if ec.enabled then
	local e_w = (F3_LABEL + (ec.e_chars or 4)) * F3_CHAR_W
	local ec_src = { x = 1, y = 37, w = e_w, h = F3_LINE_H }
	local ec_dst = {
		x = ec.x,
		y = ec.y,
		w = e_w * ec_size,
		h = F3_LINE_H * ec_size,
	}
	register_keyed("e_counter", ec_src, ec_dst, { "thin", "eyezoom", "preemptive" }, ec_keys, 2, true)
end

if ec.show_c then
	local c_w = (F3_LABEL + (ec.c_chars or 8)) * F3_CHAR_W
	local cc_src = { x = 1, y = 28, w = c_w, h = F3_LINE_H }
	local cc_dst = {
		x = ec.x,
		y = ec.c_y or (ec.y - F3_LINE_H * ec_size),
		w = c_w * ec_size,
		h = F3_LINE_H * ec_size,
	}
	register_keyed("c_counter", cc_src, cc_dst, { "thin", "eyezoom", "preemptive" }, ec_keys, 2, true)
end

-- Tall pie / number mirrors: absolute src+dst from settings.lua.
local pie = cfg.tall_pie
if pie.enabled then
	local pie_src = pie.src
	local pie_dst = pie.dst
	if pie.colorkey then
		for i, ck in ipairs(pie_colors) do
			scene:register("tall_pie_" .. i, {
				kind = "mirror",
				options = { src = pie_src, dst = pie_dst, depth = 2, color_key = ck },
				groups = { "preemptive" },
			})
		end
	else
		scene:register("tall_pie_all", {
			kind = "mirror",
			options = { src = pie_src, dst = pie_dst, depth = 2 },
			groups = { "preemptive" },
		})
	end
end

local pct = cfg.percent or { enabled = false }
local mapless = cfg.mapless or { enabled = false }
local glowdar = cfg.glowdar or { enabled = false }

-- Several strips → one dst so the glyph stays put when pie rows reorder.
local function register_stable_strips(name_prefix, src, dst, groups, keys, rows, step)
	rows = rows or 4
	step = step or 8
	for i = 0, rows - 1 do
		register_keyed(name_prefix .. "_" .. i, {
			x = src.x,
			y = src.y + step * i,
			w = src.w,
			h = src.h,
		}, dst, groups, keys, 3, true)
	end
end

if pct.enabled then
	local rows = pct.rows or 4
	local step = pct.row_step or 8
	local be_keys = {
		{
			input = "#E96D4D",
			output = pct.match_text and cfg.text_col or cfg.pie_chart_1,
		},
	}
	local un_keys = {
		{
			input = "#45CB65",
			output = pct.match_text and cfg.text_col or cfg.pie_chart_2,
		},
	}
	register_stable_strips("thin_percent_be", pct.thin_src, pct.blockentities, { "thin" }, be_keys, rows, step)
	register_stable_strips("thin_percent_un", pct.thin_src, pct.unspecified, { "thin" }, un_keys, rows, step)
	register_stable_strips("tall_percent_be", pct.tall_src, pct.blockentities, { "preemptive" }, be_keys, rows, step)
	register_stable_strips("tall_percent_un", pct.tall_src, pct.unspecified, { "preemptive" }, un_keys, rows, step)
end

if mapless.enabled then
	local rows = mapless.rows or 4
	local step = mapless.row_step or 8
	local keys = {
		{
			input = "#E96D4D",
			output = mapless.output or cfg.text_col or "#FFFFFF",
		},
	}
	register_stable_strips("thin_mapless", mapless.thin.src, mapless.thin.dst, { "thin" }, keys, rows, step)
	register_stable_strips("normal_mapless", mapless.normal.src, mapless.normal.dst, { "normal" }, keys, rows, step)
end

if glowdar.enabled then
	local rows = glowdar.rows or 4
	local step = glowdar.row_step or 8
	local keys = nil
	if glowdar.colorkey ~= false then
		keys = {}
		for _, input in ipairs(glowdar.input_colors or { "#4DE1CA", "#4EE4CC" }) do
			keys[#keys + 1] = { input = input, output = glowdar.output or "#FFFFFF" }
		end
	end
	register_stable_strips("glowdar", glowdar.src, glowdar.dst, { "normal" }, keys, rows, step)
end

local measure_w, measure_h = cfg.measuring.dst_w, cfg.measuring.dst_h
local left_gap = (display.w - tall_res.w) / 2
local measure_dst = {
	x = (left_gap - measure_w) / 2,
	y = (display.h - measure_h) / 2,
	w = measure_w,
	h = measure_h,
}

-- Boat-eye measure + overlay (eyezoom only).
scene:register("eye_measure", {
	kind = "mirror",
	options = {
		src = {
			x = (tall_res.w - cfg.measuring.src_w) / 2,
			y = (tall_res.h - cfg.measuring.src_h) / 2,
			w = cfg.measuring.src_w,
			h = cfg.measuring.src_h,
		},
		dst = measure_dst,
		depth = 0,
	},
	groups = { "eyezoom" },
})

scene:register("eye_overlay", {
	kind = "image",
	path = cfg.eye_overlay,
	options = {
		dst = measure_dst,
		depth = 1,
	},
	groups = { "eyezoom" },
})

-- === modes ===
local ModeManager = Modes.ModeManager.new(waywall)

local function mode_guard()
	return not waywall.get_key("F3")
end

-- waywork README: set_sensitivity(0) restores config.input.sensitivity
local function reset_sens()
	waywall.set_sensitivity(0)
end

-- Fullscreen-only mirrors (mapless + glowdar) live in "normal".
-- Sync after ModeManager updates `active` — never during config load
-- (waywall forbids creating mirrors at startup).
local _transition_to = ModeManager._transition_to
function ModeManager:_transition_to(name)
	_transition_to(self, name)
	scene:enable_group("normal", self.active == nil)
end

ModeManager:define("thin", {
	width = thin_res.w,
	height = thin_res.h,
	toggle_guard = mode_guard,
	on_enter = function()
		scene:enable_group("thin", true)
		reset_sens()
	end,
	on_exit = function()
		scene:enable_group("thin", false)
		reset_sens()
	end,
})

ModeManager:define("wide", {
	width = wide_res.w,
	height = wide_res.h,
	toggle_guard = mode_guard,
	on_enter = reset_sens,
	on_exit = reset_sens,
})

-- Eyezoom: boat-eye measure overlay; no tall pie mirror.
ModeManager:define("eyezoom", {
	width = tall_res.w,
	height = tall_res.h,
	toggle_guard = mode_guard,
	on_enter = function()
		scene:enable_group("eyezoom", true)
		waywall.set_sensitivity(eyezoom_sens)
	end,
	on_exit = function()
		scene:enable_group("eyezoom", false)
		reset_sens()
	end,
})

-- Preemptive: tall pie mirror; no boat-eye measure overlay.
ModeManager:define("preemptive", {
	width = tall_res.w,
	height = tall_res.h,
	toggle_guard = mode_guard,
	on_enter = function()
		scene:enable_group("preemptive", true)
		reset_sens()
	end,
	on_exit = function()
		scene:enable_group("preemptive", false)
		reset_sens()
	end,
})

local function reset_to_fullscreen()
	if ModeManager.active then
		ModeManager:_transition_to(nil)
	else
		-- pcall: set_resolution is illegal during early "load" / before a client attaches.
		pcall(waywall.set_resolution, 0, 0)
		scene:enable_group("thin", false)
		scene:enable_group("eyezoom", false)
		scene:enable_group("preemptive", false)
		scene:enable_group("normal", true)
		reset_sens()
	end
end

waywall.listen("load", function()
	-- Enable fullscreen mirrors only — do not set_resolution here (startup).
	scene:enable_group("thin", false)
	scene:enable_group("eyezoom", false)
	scene:enable_group("preemptive", false)
	scene:enable_group("normal", true)
	reset_sens()

	-- Wait for title screen before launching NinB.
	repeat
		local ok, state = pcall(waywall.state)
		waywall.sleep(1000)
	until ok and state.screen == "title"

	ensure_ninjabrain()
end)

-- Reset mode when leaving a world (world reset, quit to title, new world gen, etc.).
waywall.listen("state", function()
	local ok, state = pcall(waywall.state)
	if not ok then
		return
	end
	if state.screen ~= "inworld" then
		reset_to_fullscreen()
	end
end)

config.actions = Keys.actions({
	[cfg.keys.toggle_ninbot] = function()
		ensure_ninjabrain()
		helpers.toggle_floating()
	end,
	[cfg.keys.launch_paceman] = function()
		ensure_paceman()
	end,
	[cfg.keys.thin] = function()
		return ModeManager:toggle("thin")
	end,
	[cfg.keys.wide] = function()
		return ModeManager:toggle("wide")
	end,
	[cfg.keys.eyezoom] = function()
		return ModeManager:toggle("eyezoom")
	end,
	[cfg.keys.preemptive] = function()
		return ModeManager:toggle("preemptive")
	end,
})

require("extras")(config, {
	cfg = cfg,
	remaps = remaps,
	scene = scene,
	ModeManager = ModeManager,
	waywall = waywall,
	helpers = helpers,
})

return config
