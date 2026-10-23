{
  lib,
  stdenvNoCC,
}:

# legal-dlls.csv row libglfw.so,3.5.1-linux.
# GLFW 3.5.1 plus the waywall patch at ad569de, from
# https://github.com/r0hkx/mcsr-glfw/actions/runs/38512312952
# Republished at https://github.com/JamiKettunen/mcsr-glfw/releases/tag/20261019-v3.5.1
# The sha512 is the rules check. Strip, patchelf, or a local rebuild is a different file.
let
  sha512 = "9c6f51924ca376ba13936157778de2e7e35be34c69ab904241db32266161f3184974e08daba73eeea91afbab329b23c8e088985845562946e3c015faca9ab036";
in
stdenvNoCC.mkDerivation {
  pname = "glfw-mcsr";
  version = "3.5.1";

  src = ./glfw/libglfw.so;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp "$src" "$out/lib/libglfw.so"
    ln -s libglfw.so "$out/lib/libglfw.so.3"
    got=$(sha512sum "$out/lib/libglfw.so" | cut -d' ' -f1)
    if [ "$got" != "${sha512}" ]; then
      echo "glfw sha512 mismatch: $got" >&2
      exit 1
    fi
    runHook postInstall
  '';

  meta = {
    description = "Unmodified speedrun-legal GLFW 3.5.1 (waywall patch ad569de)";
    homepage = "https://github.com/JamiKettunen/mcsr-glfw/releases/tag/20261019-v3.5.1";
    license = lib.licenses.zlib;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
