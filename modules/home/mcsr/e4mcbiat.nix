{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.mcsr;

  e4mcbiat =
    let
      jar = pkgs.fetchurl {
        url = "https://github.com/DuncanRuns/e4mcbiat/releases/download/v0.2.2/e4mcbiat-0.2.2-all.jar";
        hash = "sha256-Okpvu3nF2kTOP22gZom9u8NryTOJbFwnNdUBYEqil6U=";
      };
      jre = pkgs.temurin-jre-bin-17;
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "e4mcbiat";
      version = "0.2.2";
      dontUnpack = true;
      nativeBuildInputs = [ pkgs.makeWrapper ];
      installPhase = ''
        mkdir -p $out/share/e4mcbiat $out/bin
        cp ${jar} $out/share/e4mcbiat/e4mcbiat.jar
        # Metal L&F: NixOS Swing blank-window fix (same as waywall NinB tip).
        # https://tesselslate.github.io/waywall/01_ninb.html
        makeWrapper ${lib.getExe' jre "java"} $out/bin/e4mcbiat \
          --add-flags "-Dawt.useSystemAAFontSettings=on" \
          --add-flags "-Dswing.defaultlaf=javax.swing.plaf.metal.MetalLookAndFeel" \
          --add-flags "-jar $out/share/e4mcbiat/e4mcbiat.jar" \
          --prefix LD_LIBRARY_PATH : ${
            lib.makeLibraryPath (
              with pkgs;
              [
                libGL
                libx11
                libxext
                libxrender
                libxtst
                libxi
                fontconfig
                freetype
                zlib
              ]
            )
          }
      '';
      meta = {
        description = "e4mc as a standalone tool for opening LAN worlds";
        homepage = "https://github.com/DuncanRuns/e4mcbiat";
        mainProgram = "e4mcbiat";
      };
    };
in
{
  options.my.home.mcsr.e4mcbiat.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install e4mcbiat (standalone e4mc LAN tunnel; no router ports)";
  };

  config = lib.mkIf (cfg.enable && cfg.e4mcbiat.enable) {
    home.packages = [ e4mcbiat ];
  };
}
