{
  features.libreoffice.homeManager =
    { lib, pkgs, ... }:
    let
      desktop = "writer.desktop";

      types = [
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        "application/msword"
        "application/vnd.oasis.opendocument.text"
        "application/rtf"
        "text/rtf"
      ];
    in
    {
      home.packages = [ pkgs.libreoffice ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs types (_: lib.mkDefault desktop);
      };
    };
}
