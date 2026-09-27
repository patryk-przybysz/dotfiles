{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.haruna;
  desktop = "org.kde.haruna.desktop";
in
{
  options.my.home.haruna.enable = lib.mkEnableOption "Haruna video player (libmpv)";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.haruna ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Higher priority than mpv's mkDefault, so video files open here.
        "video/mp4" = desktop;
        "video/x-matroska" = desktop;
        "video/webm" = desktop;
        "video/quicktime" = desktop;
      };
    };
  };
}
