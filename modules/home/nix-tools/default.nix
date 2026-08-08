{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.nix-tools;
in
{
  options.my.home.nix-tools.enable = lib.mkEnableOption "Nix ecosystem tooling";

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 10 --keep-since 14d";
      };
    };

    programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable {
      os = "nh os switch";
      osl = "nh os switch --show-activation-logs";
      ost = "nh os test";
      hm = "nh home switch";
      ncl = "nh clean all";
    };

    home.packages = [
      pkgs.nil
      pkgs.nixfmt
      pkgs.devenv
    ];
  };
}
