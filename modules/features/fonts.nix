{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.fonts;
in
{
  options.my.home.fonts.enable = lib.mkEnableOption "user fonts";

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.commit-mono
      libertine
      font-awesome
      corefonts
      vista-fonts
    ];
  };
}
