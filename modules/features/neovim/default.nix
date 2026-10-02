{ inputs, ... }:
{
  flake-file.inputs.gen-luarc = {
    url = "github:mrcjkb/nix-gen-luarc-json";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.git-hooks.follows = "git-hooks";
  };

  nixpkgs.overlays = [
    inputs.gen-luarc.overlays.default
    (import ./_overlay.nix { inherit inputs; })
  ];

  features.neovim.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nvim ];
      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };

  perSystem =
    { pkgs, ... }:
    let
      configPath = toString ./config;
    in
    {
      devShells.nvim = pkgs.mkShell {
        name = "nvim-dev";
        packages = with pkgs; [
          nvim-dev
          lua-language-server
          nil
          stylua
        ];
        shellHook = ''
          ln -fs ${pkgs.nvim-luarc-json} .luarc.json
          ln -Tfns ${configPath} "$HOME/.config/nvim-dev"
        '';
      };
    };
}
