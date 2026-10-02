{
  config,
  lib,
  perSystem,
  ...
}:
let
  cfg = config.my.home.mcsr;
  e4mcbiat = perSystem.e4mcbiat.default;
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
