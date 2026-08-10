-- Entry: mcsr-nixos bakes programs/files into this chunk only.
-- https://git.uku3lig.net/uku/mcsr-nixos/src/branch/main/doc/waywall.md
-- https://github.com/arjuncgore/waywall_generic_config

local main = require("main")
local remaps = require("remaps")
local settings = require("settings")

settings.ninjabrain_bot = programs.ninjabrain_bot
settings.paceman_tracker = programs.paceman_tracker
settings.eye_overlay = files.eye_overlay

return main(settings, remaps)
