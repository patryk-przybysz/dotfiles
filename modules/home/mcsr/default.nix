{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.mcsr;
  mcsrPkgs = inputs.mcsr.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./e4mcbiat.nix
    ./waywall
  ];

  options.my.home.mcsr.enable = lib.mkEnableOption "Minecraft speedrunning (waywall + tools)";

  config = lib.mkIf cfg.enable {
    home.packages = [
      # NVIDIA: GLFW 65544 / preemptive need this on the game process.
      # https://tesselslate.github.io/waywall/00_setup.html#nvidia
      # Wrapped on the launcher so it applies without relying on Prism Env={}.
      (pkgs.symlinkJoin {
        name = "prismlauncher";
        paths = [
          (pkgs.prismlauncher.override {
            jdks = [
              mcsrPkgs.graalvm-21
              pkgs.temurin-bin-25
              pkgs.temurin-bin-21
              pkgs.temurin-bin-17
              pkgs.temurin-bin-8
            ];

            additionalLibs = with pkgs; [
              libx11
              libxt
              libxtst
              libxcb
              libxkbcommon
              libxinerama
            ];
          })
        ];
        nativeBuildInputs = [ pkgs.makeBinaryWrapper ];
        postBuild = ''
          wrapProgram $out/bin/prismlauncher \
            --set __GL_THREADED_OPTIMIZATIONS 0
        '';
      })
      mcsrPkgs.modcheck
      mcsrPkgs.paceman-tracker
    ];
  };
}
