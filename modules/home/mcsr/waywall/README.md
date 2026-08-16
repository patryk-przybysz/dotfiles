# waywall config

[waywall](https://github.com/tesselslate/waywall) + [waywork](https://github.com/Esensats/waywork) layout for Minecraft 1.16.1 speedrunning on Niri. Managed via Home Manager through [mcsr-nixos](https://git.uku3lig.net/uku/mcsr-nixos) (`programs.waywall`).

Layout inspired by [arjuncgore/waywall_generic_config](https://github.com/arjuncgore/waywall_generic_config).

> **Not a template.** Tuned for a single resolution (2560×1600), one mouse, and my personal keybinds. Heavily vibecoded — copy ideas, not files.

## Files

| File                        | Purpose                                                                   |
| --------------------------- | ------------------------------------------------------------------------- |
| `init.lua`                  | Scenes, modes, mirrors, window layout (baked by mcsr-nixos at build time) |
| `settings.lua`              | Resolution, sensitivity, colors, mirror coordinates                       |
| `remaps.lua`                | Key/mouse remaps                                                          |
| `extras.lua`                | Chat mode toggle, dynamic keymap switching                                |
| `xkb/mc`                    | Custom XKB layout                                                         |
| `default.nix`               | Nix module — deploys files + enables `programs.waywall`                   |
| `resources/eye_overlay.png` | Eye zoom overlay asset                                                    |

Upstream docs: [mcsr-nixos waywall guide](https://git.uku3lig.net/uku/mcsr-nixos/src/branch/main/doc/waywall.md), [tesselslate waywall setup](https://tesselslate.github.io/waywall/).

## How to change config

**Do not** hot-reload by editing or copying files into `~/.config/waywall` while Minecraft is running. waywall can SIGSEGV in `config_vm_resume` and MC dies with exit 111 (compositor gone).

Instead:

1. Edit files in this directory
2. `nh home switch` (or `home-manager switch`)
3. Relaunch waywall / MC

`default.nix` deploys sibling Lua files via `home.file`; only `init.lua` is inlined by mcsr-nixos.

## NVIDIA

Prism Launcher is wrapped with `__GL_THREADED_OPTIMIZATIONS=0` on the game process (see `modules/home/mcsr/default.nix`). Required for GLFW 65544 / preemptive mode on NVIDIA — see [waywall NVIDIA setup](https://tesselslate.github.io/waywall/00_setup.html#nvidia).

Ninjabrain-bot uses a Metal LAF override to avoid blank Swing windows on NixOS — see [NixOS blank Swing window](https://tesselslate.github.io/waywall/01_ninb.html).
