{
  features.thunar = {
    nixos =
      { pkgs, ... }:
      {
        # Plugins have to be wrapped into Thunar. A bare thunar-archive-plugin
        # package never lands on THUNARX_DIRS.
        # https://nixos.org/manual/nixos/unstable/#sec-xfce-thunar-plugins
        programs.thunar = {
          enable = true;
          plugins = with pkgs; [
            thunar-archive-plugin
            thunar-media-tags-plugin
            thunar-volman
          ];
        };

        # Trash, MTP, network mounts, and the volume monitor. Also turns on udisks2.
        services.gvfs.enable = true;

        # Thumbnail daemon Thunar actually calls. The package already builds the
        # ffmpegthumbnailer plugin, plus HEIF, JPEG XL, WebP, SVG, PDF, and EPUB.
        services.tumbler.enable = true;

        # SVG icons in the GTK theme. Tumblerd sets its own pixbuf cache, so this
        # does not replace the thumbnailers above.
        programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

        # thunar-archive-plugin 0.6 ships helpers for file-roller, engrampa, and
        # ark. file-roller's desktop id is org.gnome.FileRoller. Its Nautilus
        # extension links libnautilus, so that library stays in the closure, but
        # Nautilus is not on PATH.
        environment.systemPackages = [ pkgs.file-roller ];
      };

    homeManager =
      { lib, pkgs, ... }:
      let
        catppuccinGtk = pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = [ "mauve" ];
        };
        gtkTheme = "catppuccin-mocha-mauve-standard";

        # Whatever file-roller's desktop file claims, so Extract Here does not
        # stop to ask which archive manager to use.
        archiveMimeTypes = [
          "application/bzip2"
          "application/gzip"
          "application/vnd.android.package-archive"
          "application/vnd.debian.binary-package"
          "application/vnd.ms-cab-compressed"
          "application/vnd.rar"
          "application/x-7z-compressed"
          "application/x-7z-compressed-tar"
          "application/x-ace"
          "application/x-alz"
          "application/x-apple-diskimage"
          "application/x-ar"
          "application/x-archive"
          "application/x-arj"
          "application/x-brotli"
          "application/x-bzip"
          "application/x-bzip-brotli-tar"
          "application/x-bzip-compressed-tar"
          "application/x-bzip1"
          "application/x-bzip1-compressed-tar"
          "application/x-bzip2"
          "application/x-bzip2-compressed-tar"
          "application/x-bzip3"
          "application/x-bzip3-compressed-tar"
          "application/x-cabinet"
          "application/x-cd-image"
          "application/x-chrome-extension"
          "application/x-compress"
          "application/x-compressed-tar"
          "application/x-cpio"
          "application/x-deb"
          "application/x-ear"
          "application/x-gtar"
          "application/x-gzip"
          "application/x-gzpostscript"
          "application/x-java-archive"
          "application/x-lha"
          "application/x-lhz"
          "application/x-lrzip"
          "application/x-lrzip-compressed-tar"
          "application/x-lz4"
          "application/x-lz4-compressed-tar"
          "application/x-lzip"
          "application/x-lzip-compressed-tar"
          "application/x-lzma"
          "application/x-lzma-compressed-tar"
          "application/x-lzop"
          "application/x-ms-wim"
          "application/x-rar"
          "application/x-rar-compressed"
          "application/x-rpm"
          "application/x-rzip"
          "application/x-rzip-compressed-tar"
          "application/x-source-rpm"
          "application/x-stuffit"
          "application/x-tar"
          "application/x-tarz"
          "application/x-tzo"
          "application/x-war"
          "application/x-xar"
          "application/x-xz"
          "application/x-xz-compressed-tar"
          "application/x-zip"
          "application/x-zip-compressed"
          "application/x-zoo"
          "application/x-zstd-compressed-tar"
          "application/zip"
          "application/zstd"
        ];
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
          }
          // lib.genAttrs archiveMimeTypes (_: lib.mkDefault "org.gnome.FileRoller.desktop");
        };

        xfconf.settings.thunar."misc-volume-management" = true;

        xdg.configFile."Thunar/uca.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
          <action>
          	<icon>utilities-terminal</icon>
          	<name>Open Terminal Here</name>
          	<unique-id>1740000000000000-1</unique-id>
          	<command>alacritty --working-directory "%f"</command>
          	<description>Open Alacritty in this folder</description>
          	<patterns>*</patterns>
          	<startup-notify/>
          	<directories/>
          </action>
          </actions>
        '';
      };
  };
}
