{
  features.js.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nodejs_26 ];

      programs.bun.enable = true;

      home.sessionPath = [ "$HOME/.bun/bin" ];
    };
}
