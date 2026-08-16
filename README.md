# dotfiles

Personal Nix flake for my machines — [Home Manager](https://github.com/nix-community/home-manager), [NixOS](https://nixos.org/), and [system-manager](https://github.com/numtide/system-manager) configs. Structured with [blueprint](https://github.com/numtide/blueprint).

> **Not a template.** This repo is heavily vibecoded, machine-specific, and changes without notice.

## Layout

```
.
├── flake.nix              # inputs + blueprint outputs
├── hosts/                 # per-machine configs (auto-discovered by blueprint)
├── modules/
│   ├── home/              # Home Manager modules (my.home.* options)
│   └── nixos/             # NixOS modules (my.nixos.* options)
├── checks/                # flake checks
└── devshell.nix
```

Modules are toggled per-host via `my.home.<name>.enable` and `my.nixos.<name>.enable` options.

## MCSR

Minecraft 1.16.1 speedrunning setup lives in [`modules/home/mcsr/`](modules/home/mcsr/). The interesting bits:

- **[waywall config](modules/home/mcsr/waywall/)** — mirrors, remaps ([waywall README](modules/home/mcsr/waywall/README.md))
- **NixOS tmpfs worlds** — [`modules/nixos/mcsr/`](modules/nixos/mcsr/) (dedicated RAM mount for world saves)
- **Packages** — pulled from [mcsr-nixos](https://git.uku3lig.net/uku/mcsr-nixos)
