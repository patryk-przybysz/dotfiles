{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  src,
}:
stdenv.mkDerivation {
  pname = "linuwu-sense";
  version = "1.0.2";

  inherit src;

  setSourceRoot = ''
    sourceRoot=$(echo */Linuwu-Sense)
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [
    "format"
    "pic"
  ];

  # Linux 7.2 removed strncpy() from the kernel (commit 079a028). These three
  # stores already NUL-terminate after the copy, so memcpy matches the old
  # strncpy(..., len) usage here.
  postPatch = ''
    substituteInPlace src/linuwu_sense.c \
      --replace-fail 'strncpy(input, buf, len);' 'memcpy(input, buf, len);' \
      --replace-fail 'strncpy(input_buf, buf, len);' 'memcpy(input_buf, buf, len);' \
      --replace-fail 'strncpy(str_buf, buf, len);' 'memcpy(str_buf, buf, len);'
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "KVER=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=extra"
    "DEPMOD=true"
  ];

  # Upstream `install` copies the .ko onto the host with sudo. kbuild's
  # modules_install signs the module and writes linuwu_sense.ko.cer, which
  # the kernel module aggregator concatenates into modules.cer.
  installFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];

  installTargets = [ "modules_install" ];

  meta = {
    description = "Out-of-tree Acer Predator/Nitro WMI driver used by DAMX";
    homepage = "https://github.com/PXDiv/Div-Linuwu-Sense";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
