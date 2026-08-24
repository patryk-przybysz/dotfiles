{
  lib,
  stdenv,
  autoPatchelfHook,
  zlib,
  src,
}:
stdenv.mkDerivation {
  pname = "damx-daemon";
  version = "1.0.2";

  inherit src;

  setSourceRoot = ''
    sourceRoot=$(echo */DAMX-Daemon)
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 DAMX-Daemon $out/bin/DAMX-Daemon
    ln -s DAMX-Daemon $out/bin/damx-daemon
    runHook postInstall
  '';

  meta = {
    description = "DAMX privileged daemon for Acer laptop controls";
    homepage = "https://github.com/PXDiv/Div-Acer-Manager-Max";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
  };
}
