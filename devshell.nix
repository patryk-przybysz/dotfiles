{
  inputs,
  pkgs,
  system,
  ...
}:
let
  pre-commit-check = import ./checks/pre-commit-check.nix { inherit inputs pkgs system; };
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
