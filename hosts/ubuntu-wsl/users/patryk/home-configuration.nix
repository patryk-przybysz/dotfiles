{
  pkgs,
  config,
  ...
}:
{
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

  programs.fish = {
    enable = true;
    shellInit = ''
      # Nix
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      end

      # Rootless podman needs setuid newuidmap from system-manager wrappers.
      # /etc/profile.d/system-manager-path.sh is not sourced by fish.
      if test -d /run/wrappers/bin
        fish_add_path -m /run/wrappers/bin
      end
    '';
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
  programs.starship.enable = true;

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
