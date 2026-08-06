{
  pkgs,
  inputs,
  ...
}:
{
  imports = builtins.attrValues inputs.self.homeModules;

  my.home = {
    cli.enable = true;
    cpp.enable = true;
    direnv.enable = true;
    fish.enable = true;
    fonts.enable = true;
    gh.enable = true;
    git.enable = true;
    herdr.enable = true;
    js.enable = true;
    jujutsu.enable = true;
    neovim.enable = true;
    nix-tools.enable = true;
    podman.enable = true;
    python.enable = true;
    rust.enable = true;
    starship.enable = true;
  };

  home.stateVersion = "25.05";

  # Not yet modularized
  home.packages = with pkgs; [
    ormolu
    devcontainer
    typst
    oci-cli
    terraform
    ffmpeg
    yt-dlp
  ];

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
}
