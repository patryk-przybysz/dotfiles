{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.nautilus;
  fileRoller = "org.gnome.FileRoller.desktop";
in
{
  options.my.home.nautilus.enable = lib.mkEnableOption "Nautilus file manager";

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Thunar also claims folders; this wins while both are installed.
        "inode/directory" = lib.mkForce "org.gnome.Nautilus.desktop";
        "application/zip" = fileRoller;
        "application/x-tar" = fileRoller;
        "application/gzip" = fileRoller;
        "application/x-compressed-tar" = fileRoller;
        "application/x-bzip" = fileRoller;
        "application/x-bzip-compressed-tar" = fileRoller;
        "application/x-xz" = fileRoller;
        "application/x-xz-compressed-tar" = fileRoller;
        "application/x-7z-compressed" = fileRoller;
        "application/vnd.rar" = fileRoller;
        "application/x-rar" = fileRoller;
      };
    };

    home.packages = with pkgs; [
      nautilus
      file-roller
    ];
  };
}
