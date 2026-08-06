{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.fish;
in
{
  options.my.home.fish.enable = lib.mkEnableOption "fish shell (with bash login wrapper)";

  config = lib.mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
        enableCompletion = false;
        # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
        profileExtra = ''
          if [ -n "''${BASH_VERSION:-}" ] && [[ $- == *i* ]] \
              && [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ]] \
              && [ -z "''${BASH_EXECUTION_STRING}" ] \
              && [ -z "''${IN_NIX_SHELL:-}" ]; then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
        initExtra = lib.mkOrder 50 ''
          if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" \
                && -z ''${BASH_EXECUTION_STRING} \
                && -z ''${IN_NIX_SHELL:-} ]]; then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
          fi
        '';
      };

      fish = {
        enable = true;
        plugins = with pkgs; [
          {
            name = "autopair";
            src = fishPlugins.autopair.src;
          }
          {
            name = "abbr-tips";
            src = fetchFromGitHub {
              owner = "gazorby";
              repo = "fish-abbreviation-tips";
              rev = "v0.7.0";
              hash = "sha256-F1t81VliD+v6WEWqj1c1ehFBXzqLyumx5vV46s/FZRU=";
            };
          }
        ];
      };
    };
  };
}
