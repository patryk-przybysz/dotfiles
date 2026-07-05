{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.neovim
  ];

  home.stateVersion = "25.05";

  services.podman = {
    enable = true;
    settings.containers.compose_warning_logs = false;
  };

  home.packages = with pkgs; [
    podman-compose
    docker-language-server
    ormolu

    devcontainer
    typst
    fastfetch
    rustup
    devenv
    oci-cli
    terraform

    # C/C++
    gcc
    cmake
    gnumake

    # JS
    nodejs_26

    # Nix
    nil
    nixfmt

    # Fonts
    nerd-fonts.commit-mono
    libertine
    font-awesome
    corefonts
    vista-fonts
  ];

  fonts.fontconfig.enable = true;

  programs.bash = {
    enable = true;
    # Keep bash as login shell (POSIX); exec fish for interactive use.
    # HM .bash_profile sources .profile then .bashrc for login shells.
    # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
    initExtra = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" \
            && -z ''${BASH_EXECUTION_STRING} \
            && -z ''${IN_NIX_SHELL:-} ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish = {
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.nix-your-shell.enable = true;
  programs.starship = {
    enable = true;
    presets = [ "nerd-font-symbols" ];
    settings = {
      nix_shell.heuristic = true;
    };
  };

  programs.bun.enable = true;
  programs.uv.enable = true;

  programs.zoxide.enable = true;
  programs.fd.enable = true;
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.zellij.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Patryk Przybysz";
        email = "pprzybysz04@outlook.com";
        github = "patryk-przybysz";
      };
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  nix = {
    package = pkgs.nix;
    settings = {
      extra-experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
  };
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 14d";
    };
  };
}
