{ pkgs, ... }: {
  home.packages = [ pkgs.nvim ];
  environment.variables = {
    EDITOR = "nvim";
  };
}
