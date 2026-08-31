{ inputs, system, ... }:
inputs.self.legacyPackages.${system}.homeConfigurations."patryk@ubuntu-wsl".activationPackage
