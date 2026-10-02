{
  features.haruna.homeManager =
    { lib, pkgs, ... }:
    let
      desktop = "org.kde.haruna.desktop";

      # Open URL calls QStandardPaths::findExecutable("yt-dlp"). nixpkgs rewrites a
      # different string in application.cpp, so the baked path is never consulted.
      haruna = pkgs.symlinkJoin {
        name = "haruna-with-yt-dlp";
        paths = [ pkgs.haruna ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/haruna" \
            --prefix PATH : ${lib.makeBinPath [ pkgs.yt-dlp ]}
        '';
      };
    in
    {
      home.packages = [ haruna ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "video/mp4" = lib.mkDefault desktop;
          "video/x-matroska" = lib.mkDefault desktop;
          "video/webm" = lib.mkDefault desktop;
          "video/quicktime" = lib.mkDefault desktop;
        };
      };
    };
}
