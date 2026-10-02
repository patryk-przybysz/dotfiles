{
  features.nautilus = {
    nixos.services.gvfs.enable = true;

    homeManager =
      { lib, pkgs, ... }:
      {
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
  };
}
