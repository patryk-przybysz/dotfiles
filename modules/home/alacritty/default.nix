{
  config,
  lib,
  ...
}:
let
  cfg = config.my.home.alacritty;
in
{
  options.my.home.alacritty.enable = lib.mkEnableOption "Alacritty terminal";

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font.normal.family = "CommitMono Nerd Font";
      };
    };
  };
}
