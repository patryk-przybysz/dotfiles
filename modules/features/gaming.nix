{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.gaming;
in
{
  options.my.home.gaming.enable = lib.mkEnableOption "gaming launchers";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.faugus-launcher ];
  };
}
