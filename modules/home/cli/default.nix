{
  config,
  lib,
  pkgs,
  perSystem,
  ...
}:
let
  cfg = config.my.home.cli;
in
{
  options.my.home.cli.enable = lib.mkEnableOption "core CLI tools";

  config = lib.mkIf cfg.enable {
    programs = {
      fzf = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = false;
      };
      nix-your-shell.enable = true;
      zoxide = {
        enable = true;
        enableBashIntegration = false;
      };
      fd.enable = true;
      bat.enable = true;
      ripgrep.enable = true;
      htop.enable = true;
      jq.enable = true;
    };

    home.packages = with pkgs; [
      tree
      unzip
      zip
      curl
      wget
      fastfetch
      perSystem.sem.default
    ];
  };
}
