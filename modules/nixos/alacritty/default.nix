{
  config,
  lib,
  ...
}:
let
  cfg = config.my.nixos.alacritty;
in
{
  options.my.nixos.alacritty.enable = lib.mkEnableOption "Alacritty as the session terminal";

  # The context entry is only useful once Nautilus is installed.
  config = lib.mkIf cfg.enable {
    programs.nautilus-open-any-terminal = lib.mkIf config.my.nixos.nautilus.enable {
      enable = true;
      terminal = "alacritty";
    };
  };
}
