{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.js;
in
{
  options.my.home.js.enable = lib.mkEnableOption "JavaScript toolchain (node, bun, pnpm)";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nodejs_26 ];

    programs.bun.enable = true;

    home.sessionPath = [ "$HOME/.bun/bin" ];
  };
}
