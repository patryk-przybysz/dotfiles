{ pkgs, ... }: {
  home.packages = [ pkgs.nvim ];
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
