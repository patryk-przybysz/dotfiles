{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.home.podman;
in
{
  options.my.home.podman.enable = lib.mkEnableOption "rootless podman";

  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;
      settings.containers.compose_warning_logs = false;
    };

    home.packages = with pkgs; [
      podman-compose
      docker-language-server
    ];
  };
}
