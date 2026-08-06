{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.rust;
in
{
  options.my.home.rust.enable = lib.mkEnableOption "Rust toolchain (rustup)";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rustup ];
  };
}
