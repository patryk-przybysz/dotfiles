{
  features.python.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.python3 ];
      programs.uv.enable = true;
    };
}
