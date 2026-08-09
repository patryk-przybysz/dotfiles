{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.thunar;

  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "mauve" ];
  };
  gtkTheme = "catppuccin-mocha-mauve-standard";
in
{
  options.my.home.thunar.enable = lib.mkEnableOption "Thunar file manager with Catppuccin GTK theme";

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      theme = {
        name = gtkTheme;
        package = catppuccinGtk;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4 = {
        theme = {
          name = gtkTheme;
          package = catppuccinGtk;
        };
        extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
      };
    };

    home.packages = with pkgs; [
      thunar
      thunar-archive-plugin
      thunar-volman
      gvfs
    ];
  };
}
