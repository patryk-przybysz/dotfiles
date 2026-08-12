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

local display = { w = cfg.fullscreen[1], h = cfg.fullscreen[2] }
local thin = { w = cfg.thin[1], h = cfg.thin[2] }
local wide = { w = cfg.wide[1], h = cfg.wide[2] }
local tall = { w = cfg.tall[1], h = cfg.tall[2] }

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
-- opts: optional flags only — e.g. { use_border = false }. Omit (or true) to allow outlines.
local function register_keyed(name_prefix, src, dst, groups, keys, depth, opts)
	opts = opts or {}
	local d = depth or 2
	if opts.use_border ~= false and border_cfg.enabled and keys then
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

-- Several strips → one dst so the glyph stays put when pie rows reorder.
local function register_stable_strips(name_prefix, src, dst, groups, keys, rows, step, opts)
	rows = rows or 4
	step = step or 8
	for i = 0, rows - 1 do
		register_keyed(name_prefix .. "_" .. i, {
			x = src.x,
			y = src.y + step * i,
			w = src.w,
			h = src.h,
		}, dst, groups, keys, 3, opts)
	end
end

-- Mirrors from settings.mirrors[].
-- m.defaults = shared input/output/modes/src/dst/depth/use_border; each item may override.
-- Optional stable = { rows, row_step } → stable strips instead of a single absolute mirror.
for _, m in ipairs(cfg.mirrors or {}) do
	if m.enabled ~= false then
		local dfl = m.defaults or {}
		local items = m.items
		local stable = m.stable
		local rows = stable and (stable.rows or 4)
		local step = stable and (stable.row_step or 8)
		local function register_mirror(name, src, dst, modes, keys, depth, opts)
			if stable then
				register_stable_strips(name, src, dst, modes, keys, rows, step, opts)
			else
				register_keyed(name, src, dst, modes, keys, depth or 2, opts)
			end
		end
		if not items or #items == 0 then
			local keys = nil
			if dfl.input ~= nil then
				keys = { { input = dfl.input, output = dfl.output or cfg.text_col } }
			end
			register_mirror(m.name, dfl.src, dfl.dst, dfl.modes, keys, dfl.depth, {
				use_border = dfl.use_border,
			})
		else
			for i, item in ipairs(items) do
				local input = item.input or dfl.input
				local keys = nil
				if input ~= nil then
					keys = { { input = input, output = item.output or dfl.output or cfg.text_col } }
				end
				local use_border = dfl.use_border
				if item.use_border ~= nil then
					use_border = item.use_border
				end
				register_mirror(
					m.name .. "_" .. i,
					item.src or dfl.src,
					item.dst or dfl.dst,
					item.modes or dfl.modes,
					keys,
					item.depth or dfl.depth,
					{ use_border = use_border }
				)
			end
		end
	end
end

local measure_w, measure_h = cfg.measuring.dst_w, cfg.measuring.dst_h
local left_gap = (display.w - tall.w) / 2
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
			x = (tall.w - cfg.measuring.src_w) / 2,
			y = (tall.h - cfg.measuring.src_h) / 2,
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

local function enter_fullscreen_groups()
	scene:enable_group("thin", false)
	scene:enable_group("eyezoom", false)
	scene:enable_group("preemptive", false)
	scene:enable_group("fullscreen", true)
	reset_sens()
end

-- Native resolution via 0,0 (waywork exit_active uses the same).
ModeManager:define("fullscreen", {
	width = 0,
	height = 0,
	on_enter = enter_fullscreen_groups,
	on_exit = function()
		scene:enable_group("fullscreen", false)
	end,
})

-- Route nil → fullscreen so toggle-off never leaves an unmodeled state.
local function go(name)
	ModeManager:_transition_to(name == nil and "fullscreen" or name)
end

function ModeManager:toggle(name)
	local def = self.defs[name]
	if not def then
		return
	end
	if def.toggle_guard and def.toggle_guard() == false then
		return false
	end
	if name == self.active then
		go("fullscreen")
	else
		go(name)
	end
end

ModeManager:define("thin", {
	width = thin.w,
	height = thin.h,
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
	width = wide.w,
	height = wide.h,
	toggle_guard = mode_guard,
	on_enter = reset_sens,
	on_exit = reset_sens,
})

-- Eyezoom: boat-eye measure overlay; no tall pie mirror.
ModeManager:define("eyezoom", {
	width = tall.w,
	height = tall.h,
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
	width = tall.w,
	height = tall.h,
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
	if ModeManager.active and ModeManager.active ~= "fullscreen" then
		go("fullscreen")
	else
		-- pcall: set_resolution is illegal during early "load" / before a client attaches.
		pcall(waywall.set_resolution, 0, 0)
		enter_fullscreen_groups()
		ModeManager.active = "fullscreen"
	end
end

waywall.listen("load", function()
	-- Enable fullscreen mirrors only — do not set_resolution here (startup).
	enter_fullscreen_groups()
	ModeManager.active = "fullscreen"

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
