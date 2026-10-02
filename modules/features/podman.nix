{
  features.podman.homeManager =
    { pkgs, ... }:
    {
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
