{
  pkgs,
  config,
  ...
}:
{
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
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

  programs.bun.enable = true;
  programs.uv.enable = true;

  programs.fd.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.zellij.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
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
