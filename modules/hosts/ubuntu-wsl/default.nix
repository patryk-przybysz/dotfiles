{
  config,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.system-manager = {
    url = "github:numtide/system-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.userborn.inputs.systems.follows = "systems";
  };

  homes."patryk@ubuntu-wsl" = {
    system = "x86_64-linux";

    includes = with config.features; [
      cpp
      podman
      python
      rust
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.stateVersion = "25.05";

        # Not yet modularized
        home.packages = with pkgs; [
          ormolu
          devcontainer
          typst
          oci-cli
          terraform
          ffmpeg
          yt-dlp
        ];

        nix = {
          package = pkgs.nix;
          settings = {
            extra-experimental-features = [
              "nix-command"
              "flakes"
            ];
            auto-optimise-store = true;
            extra-substituters = [
              "https://nix-community.cachix.org"
              "https://devenv.cachix.org"
            ];
            extra-trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "devenv.cachix.org-1:w1c0WM8sbBS/+2QQVKqHsBrun/NoCVH2EHnumwgLc4I="
            ];
          };
        };
      };
  };

  # system-manager has no feature halves, so it stays a single inline module.
  flake.systemConfigs.ubuntu-wsl = inputs.system-manager.lib.makeSystemConfig {
    modules = [
      (
        { pkgs, ... }:
        {
          nixpkgs.hostPlatform = "x86_64-linux";

          services.userborn.enable = true;

          security.wrappers = {
            newuidmap = {
              setuid = true;
              owner = "root";
              group = "root";
              source = "${pkgs.shadow.out}/bin/newuidmap";
            };
            newgidmap = {
              setuid = true;
              owner = "root";
              group = "root";
              source = "${pkgs.shadow.out}/bin/newgidmap";
            };
          };

          users.users.patryk = {
            isNormalUser = true;
            shell = pkgs.bash;
            extraGroups = [
              "libvirt"
            ];
          };
        }
      )
    ];
  };

  perSystem =
    { system, ... }:
    {
      checks = lib.optionalAttrs (system == "x86_64-linux") {
        system-ubuntu-wsl = config.flake.systemConfigs.ubuntu-wsl;
      };
    };
}
