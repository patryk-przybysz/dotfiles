{
  description = "Home Manager configuration of patryk";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.userborn.inputs.systems.follows = "systems";
    };

    gen-luarc = {
      url = "github:mrcjkb/nix-gen-luarc-json";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    sem = {
      url = "github:Ataraxy-Labs/sem";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
        flake-utils.inputs.systems.follows = "systems";
      };
    };

    noctalia.url = "github:noctalia-dev/noctalia";
    noctalia.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    # Minecraft speedrunning packages + waywall HM/NixOS modules
    # https://git.uku3lig.net/uku/mcsr-nixos
    mcsr = {
      url = "git+https://git.uku3lig.net/uku/mcsr-nixos.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # e4mc as a standalone tool (built from source)
    # https://github.com/patryk-przybysz/e4mcbiat-nix
    e4mcbiat = {
      url = "github:patryk-przybysz/e4mcbiat-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      nixpkgs = {
        config.allowUnfree = true;
        overlays = [
          inputs.gen-luarc.overlays.default
          (import ./modules/home/neovim/overlay.nix { inherit inputs; })
          (import ./modules/home/niri/overlay.nix)
        ];
      };
    };
}
