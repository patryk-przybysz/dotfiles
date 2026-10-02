{
  config,
  inputs,
  lib,
  ...
}:
{
  options.nixpkgs.overlays = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    default = [ ];
    description = "Overlays for the nixpkgs shared by every machine, home and devShell.";
  };

  config = {
    flake-file.inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    perSystem =
      { system, ... }:
      {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          inherit (config.nixpkgs) overlays;
        };
      };
  };
}
