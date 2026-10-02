{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.python;
in
{
  options.my.home.python.enable = lib.mkEnableOption "Python toolchain (python3, uv)";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.python3 ];
    programs.uv.enable = true;
  };
}
