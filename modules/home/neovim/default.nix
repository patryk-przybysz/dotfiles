{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.neovim;
in
{
  options.my.home.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.nvim ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
