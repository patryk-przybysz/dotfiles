{ inputs, ... }:
{
  # e4mc as a standalone tool (built from source)
  # https://github.com/patryk-przybysz/e4mcbiat-nix
  flake-file.inputs.e4mcbiat = {
    url = "github:patryk-przybysz/e4mcbiat-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  features.mcsr.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.my.home.mcsr.e4mcbiat.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install e4mcbiat (standalone e4mc LAN tunnel; no router ports)";
      };

      config = lib.mkIf config.my.home.mcsr.e4mcbiat.enable {
        home.packages = [ inputs.e4mcbiat.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      };
    };
}
