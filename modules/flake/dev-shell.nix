{ lib, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          statix
          stylua
        ];
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };

      checks = lib.mapAttrs' (name: lib.nameValuePair "devshell-${name}") config.devShells;
    };
}
