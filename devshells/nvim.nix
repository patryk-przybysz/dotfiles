{
  pkgs,
  ...
}:
let
  configPath = toString ../modules/home/neovim/config;
in
pkgs.mkShell {
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
}
