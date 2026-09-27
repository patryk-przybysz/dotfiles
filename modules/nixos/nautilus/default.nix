{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixos.nautilus;
in
{
  options.my.nixos.nautilus.enable = lib.mkEnableOption "Nautilus file manager";

  config = lib.mkIf cfg.enable {
    services.gvfs.enable = true;
  };
}
