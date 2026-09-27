{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixos.niri;
in
{
  options.my.nixos.niri.enable = lib.mkEnableOption "niri compositor";

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
  };
}
