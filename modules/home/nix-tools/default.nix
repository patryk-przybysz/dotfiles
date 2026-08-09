{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.nix-tools;

  flakePath = if cfg.flake != null then cfg.flake else "${config.home.homeDirectory}/dotfiles";

  osFlake =
    if cfg.osFlake != null then
      cfg.osFlake
    else if cfg.osHost != null then
      "${flakePath}#${cfg.osHost}"
    else
      null;
in
{
  options.my.home.nix-tools = {
    enable = lib.mkEnableOption "Nix ecosystem tooling";

    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/patryk/dotfiles";
      description = ''
        Path to the dotfiles flake root. Sets {env}`NH_FLAKE`.
        Defaults to {file}`$HOME/dotfiles`.
      '';
    };

    osHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "an16-41";
      description = ''
        NixOS configuration name for {command}`nh os` commands.
        When set, {env}`NH_OS_FLAKE` becomes {code}`<flake>#<osHost>`.
      '';
    };

    osFlake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/home/patryk/dotfiles#an16-41";
      description = ''
        Full flake reference for {command}`nh os` commands. Sets {env}`NH_OS_FLAKE`
        and takes priority over {option}`my.home.nix-tools.osHost`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nh = {
      enable = true;
      flake = flakePath;
      inherit osFlake;
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
