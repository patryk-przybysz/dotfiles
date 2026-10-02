{
  features.thunar.homeManager =
    { lib, pkgs, ... }:
    let
      catppuccinGtk = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "mauve" ];
      };
      gtkTheme = "catppuccin-mocha-mauve-standard";
    in
    {
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
          "inode/directory" = lib.mkDefault "thunar.desktop";
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
