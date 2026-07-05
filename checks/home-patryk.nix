{ inputs, pkgs, ... }:
inputs.self.legacyPackages.${pkgs.system}.homeConfigurations."patryk@ubuntu-wsl".activationPackage
