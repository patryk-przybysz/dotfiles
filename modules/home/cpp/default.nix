{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.cpp;
in
{
  options.my.home.cpp.enable = lib.mkEnableOption "C/C++ build toolchain";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gcc
      cmake
      gnumake
    ];
  };
}
