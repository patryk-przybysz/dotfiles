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

    generationLabels = {
      enable = lib.mkEnableOption ''
        helpers for {option}`system.nixos.label` / {env}`NIXOS_LABEL`
      '';

      flakePath = lib.mkOption {
        type = lib.types.str;
        default = flakePath;
        description = ''
          Flake root used by {command}`ostag` when appending a git revision to
          {env}`NIXOS_LABEL_VERSION` (the pattern documented in nixpkgs).
        '';
      };
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

    programs.fish = lib.mkIf config.programs.fish.enable (
      {
        shellAbbrs = {
          os = "nh os switch";
          osl = "nh os switch --show-activation-logs";
          ost = "nh os test";
          hm = "nh home switch";
          ncl = "nh clean all";
          gens = "nixos-rebuild list-generations";
        };
      }
      // lib.optionalAttrs cfg.generationLabels.enable {
        functions.ostag = {
          description = "Switch NixOS with a boot-menu label (sets NIXOS_LABEL for this rebuild)";
          body = ''
            argparse l/show-activation-logs -- $argv
            or return

            if test (count $argv) -lt 1
                echo "usage: ostag <label> [-l]" >&2
                echo "Sets NIXOS_LABEL for one rebuild; shown in the Limine boot menu." >&2
                return 1
            end

            set -lx NIXOS_LABEL $argv[1]
            set -argv $argv[2..-1]

            set -l rev (${pkgs.git}/bin/git -C ${lib.escapeShellArg cfg.generationLabels.flakePath} rev-parse --short HEAD 2>/dev/null)
            if test -n "$rev"
                set -lx NIXOS_LABEL_VERSION "$rev"
            end

            if set -q _flag_show_activation_logs
                nh os switch --show-activation-logs $argv
            else
                nh os switch $argv
            end
          '';
        };
      }
    );

    home.packages = [
      pkgs.nil
      pkgs.nixfmt
      pkgs.devenv
    ];
  };
}
