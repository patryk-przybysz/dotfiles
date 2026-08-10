return function(config, ctx)
	local cfg = ctx.cfg
	local waywall = ctx.waywall
	local keyboard_remaps = ctx.remaps.remapped_kb or {}
	local other_remaps = ctx.remaps.normal_kb or {}
	local xkb = cfg.xkb
	local chat = cfg.chat_mode

	local remaps_active = true
	local chat_text = nil

	local function gaming_keymap()
		return {
			layout = xkb.layout,
			rules = xkb.rules,
			variant = xkb.variant,
			options = xkb.options,
		}
	end

	local function chat_keymap()
		return {
			layout = xkb.chat_layout or "pl",
			rules = nil,
			variant = nil,
			options = nil,
		}
	end

	local function wrap_mode_action(action)
		return function(...)
			if not remaps_active then
				return false
			end
			return action(...)
		end
	end

	for _, key in ipairs({
		cfg.keys.thin,
		cfg.keys.wide,
		cfg.keys.eyezoom,
		cfg.keys.preemptive,
	}) do
		local action = config.actions[key]
		if action then
			config.actions[key] = wrap_mode_action(action)
		end
	end

	config.actions[chat.toggle_key] = function()
		if chat_text then
			chat_text:close()
			chat_text = nil
		end

		if remaps_active then
			remaps_active = false
			waywall.set_remaps(other_remaps)
			if xkb.enabled then
				waywall.set_keymap(chat_keymap())
			end
			if chat.text and chat.text ~= "" then
				chat_text = waywall.text(chat.text, {
					x = chat.x,
					y = chat.y,
					color = chat.color,
					size = chat.size,
				})
			end
		else
			remaps_active = true
			waywall.set_remaps(keyboard_remaps)
			if xkb.enabled then
				waywall.set_keymap(gaming_keymap())
			end
		end
	end
end
