{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.noctalia;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  options.my.home.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ];

    programs.noctalia = {
      enable = true;

      settings = {
        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = true;
        };
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        location.address = "Gdansk, Poland";

        weather = {
          enabled = true;
          unit = "celsius";
        };

        shell = {
          time_format = "{:%a, %d %b %H:%M}";
          font_family = "CommitMono Nerd Font";
          clipboard_enabled = true;
          clipboard_history_max_entries = 20;
        };

        bar.main = {
          position = "top";

          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "clock"
            "weather"
          ];
          end = [
            "mic"
            "volume"
            "cpu"
            "memory"
            "battery"
            "clipboard"
            "notifications"
            "session"
          ];
        };

        widget = {
          mic = {
            type = "volume";
            device = "input";
          };
          cpu = {
            type = "sysmon";
            stat = "cpu_usage";
          };
          memory = {
            type = "sysmon";
            stat = "ram_used";
          };
        };
      };
    };
  };
}
