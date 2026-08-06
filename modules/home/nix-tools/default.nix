{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.nix-tools;
in
{
  options.my.home.nix-tools.enable = lib.mkEnableOption "Nix ecosystem tooling";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.nil
      pkgs.nixfmt
      pkgs.devenv
    ];
  };
}
