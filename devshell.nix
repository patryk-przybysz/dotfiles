{ inputs, pkgs, ... }:
let
  pre-commit-check = import ./checks/pre-commit-check.nix { inherit inputs pkgs; };
in
pkgs.mkShell {
  packages = with pkgs; [
    nil
    statix
    stylua
  ];
  shellHook = ''
    ${pre-commit-check.shellHook}
  '';
}
