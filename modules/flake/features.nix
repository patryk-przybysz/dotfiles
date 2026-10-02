{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  inherit (lib) types mkOption;
  inherit (config) features;

  # Features, machines, users on a machine and standalone homes all share this shape.
  shape = id: {
    options = {
      id = mkOption {
        type = types.str;
        default = id;
        readOnly = true;
        internal = true;
      };
      includes = mkOption {
        type = types.listOf types.raw;
        default = [ ];
        description = "Features pulled in alongside this one.";
      };
      nixos = mkOption {
        type = types.deferredModule;
        default = { };
        description = "NixOS half.";
      };
      homeManager = mkOption {
        type = types.deferredModule;
        default = { };
        description = "home-manager half.";
      };
    };
  };

  hostType = types.submodule (
    { name, ... }:
    let
      host = name;
    in
    {
      imports = [ (shape "host:${host}") ];
      options.users = mkOption {
        type = types.attrsOf (types.submodule ({ name, ... }: shape "user:${name}@${host}"));
        default = { };
        description = "Users on this machine. What they list applies its home half to them only.";
      };
    }
  );

  homeType = types.submodule (
    { name, ... }:
    {
      imports = [ (shape "home:${name}") ];
      options.system = mkOption {
        type = types.str;
        description = "System the standalone home is built for.";
      };
    }
  );

  # Every feature reachable from `roots`, each one once.
  closure =
    roots:
    map (e: e.f) (
      builtins.genericClosure {
        startSet = map (f: {
          key = f.id;
          inherit f;
        }) roots;
        operator =
          e:
          map (f: {
            key = f.id;
            inherit f;
          }) e.f.includes;
      }
    );

  # Keyed, so the module system applies a half once even if it is reached twice.
  halves =
    class: roots:
    map (f: {
      key = "${f.id}/${class}";
      imports = [ f.${class} ];
    }) (closure roots);

  everywhere = user: lib.optional (features ? ${user}) features.${user};

  pkgsFor = system: withSystem system ({ pkgs, ... }: pkgs);
in
{
  options = {
    features = mkOption {
      type = types.lazyAttrsOf (types.submodule ({ name, ... }: shape "feature:${name}"));
      default = { };
      description = "Reusable features. `features.<user>` is what that user gets everywhere.";
    };
    hosts = mkOption {
      type = types.attrsOf hostType;
      default = { };
      description = "NixOS machines.";
    };
    homes = mkOption {
      type = types.attrsOf homeType;
      default = { };
      description = "Standalone home-manager configurations, named `<user>@<machine>`.";
    };
  };

  config = {
    flake-file.inputs.home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake.nixosConfigurations = lib.mapAttrs (
      _: host:
      let
        users = lib.attrNames host.users;
        userRoots = user: everywhere user ++ [ host.users.${user} ];
      in
      inputs.nixpkgs.lib.nixosSystem {
        modules = [
          (
            { config, ... }:
            {
              nixpkgs.pkgs = lib.mkDefault (pkgsFor config.nixpkgs.hostPlatform.system);
            }
          )
        ]
        ++ halves "nixos" ([ host ] ++ lib.concatMap userRoots users)
        ++ lib.optional (users != [ ]) {
          imports = [ inputs.home-manager.nixosModules.home-manager ];
          home-manager = {
            useGlobalPkgs = lib.mkDefault true;
            useUserPackages = lib.mkDefault true;
            users = lib.genAttrs users (user: {
              imports = halves "homeManager" ([ host ] ++ userRoots user);
            });
          };
        };
      }
    ) config.hosts;

    flake.homeConfigurations = lib.mapAttrs (
      name: home:
      let
        user = lib.head (lib.splitString "@" name);
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsFor home.system;
        modules = halves "homeManager" (everywhere user ++ [ home ]) ++ [
          {
            home.username = lib.mkDefault user;
            home.homeDirectory = lib.mkDefault "/home/${user}";
          }
        ];
      }
    ) config.homes;

    perSystem =
      { system, ... }:
      {
        checks =
          lib.mapAttrs' (name: nixos: lib.nameValuePair "nixos-${name}" nixos.config.system.build.toplevel) (
            lib.filterAttrs (
              _: nixos: nixos.config.nixpkgs.hostPlatform.system == system
            ) config.flake.nixosConfigurations
          )
          // lib.mapAttrs' (name: home: lib.nameValuePair "home-${name}" home.activationPackage) (
            lib.filterAttrs (name: _: config.homes.${name}.system == system) config.flake.homeConfigurations
          );
      };
  };
}
