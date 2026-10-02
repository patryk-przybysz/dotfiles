{ config, ... }:
{
  # What patryk gets on every machine and standalone home.
  features.patryk.includes = with config.features; [
    cli
    direnv
    fish
    fonts
    gh
    git
    herdr
    js
    jujutsu
    neovim
    nix-tools
    starship
  ];
}
