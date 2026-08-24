{
  lib,
  stdenv,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  wrapGAppsHook3,
  cairo,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  icu,
  krb5,
  libdrm,
  libGL,
  libglvnd,
  libICE,
  libSM,
  libX11,
  libXcursor,
  libXdamage,
  libXext,
  libXi,
  libXinerama,
  libXrandr,
  libxcb,
  mesa,
  openssl,
  pango,
  zlib,
  src,
}:
let
  runtimeLibs = [
    cairo
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    icu
    krb5
    libdrm
    libGL
    libglvnd
    libICE
    libSM
    libX11
    libXcursor
    libXdamage
    libXext
    libXi
    libXinerama
    libXrandr
    libxcb
    mesa
    openssl
    pango
    stdenv.cc.cc.lib
    zlib
  ];
in
stdenv.mkDerivation {
  pname = "damx-gui";
  version = "1.0.2";

  inherit src;

  setSourceRoot = ''
    sourceRoot=$(echo */DAMX-GUI)
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  desktopItems = [
    (makeDesktopItem {
      name = "damx";
      desktopName = "DAMX";
      comment = "Div Acer Manager Max";
      exec = "DAMX";
      icon = "damx";
      categories = [
        "System"
        "Utility"
      ];
      keywords = [
        "acer"
        "laptop"
        "nitro"
        "predator"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/damx $out/share/icons/hicolor/256x256/apps
    cp -r ./* $out/share/damx/
    chmod +x $out/share/damx/DivAcerManagerMax
    if [ -f icon.png ]; then
      install -Dm644 icon.png $out/share/icons/hicolor/256x256/apps/damx.png
    fi
    makeWrapper $out/share/damx/DivAcerManagerMax $out/bin/DAMX \
      --chdir $out/share/damx \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}:$out/share/damx" \
      --set DOTNET_SYSTEM_GLOBALIZATION_INVARIANT 0
    ln -s DAMX $out/bin/damx-gui
    runHook postInstall
  '';

  meta = {
    description = "DAMX GUI for Acer Nitro/Predator Sense features";
    homepage = "https://github.com/PXDiv/Div-Acer-Manager-Max";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "DAMX";
  };
}
