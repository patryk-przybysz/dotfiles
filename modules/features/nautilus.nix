{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.nautilus;
in
{
  options.my.home.nautilus.enable = lib.mkEnableOption "Nautilus file manager";

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = lib.mkDefault "org.gnome.Nautilus.desktop";
      };
    };

    # file-roller is the Nautilus extension (Extract Here / Extract To), not a default opener.
    home.packages = with pkgs; [
      nautilus
      file-roller
    ];
  };
}
