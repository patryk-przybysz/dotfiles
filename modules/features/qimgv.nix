{
  features.qimgv.homeManager =
    { lib, pkgs, ... }:
    let
      desktop = "qimgv.desktop";

      common = [
        "image/jpeg"
        "image/png"
        "image/gif"
        "image/webp"
      ];

      extra = [
        "image/svg+xml"
        "image/svg+xml-compressed"
        "image/tiff"
        "image/avif"
        "image/heif"
        "image/heic"
        "image/jxl"
        "image/vnd.microsoft.icon"
      ];
    in
    {
      home.packages = [ pkgs.qimgv ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs (common ++ extra) (_: lib.mkDefault desktop);
        associations.added = lib.genAttrs extra (_: [ desktop ]);
      };
    };
}
