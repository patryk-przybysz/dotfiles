{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.noctalia;
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpaperFile = "${wallpaperDir}/sylas.jpg";
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

        wallpaper = {
          enabled = true;
          fill_mode = "crop";
          directory = wallpaperDir;
          default.path = wallpaperFile;
        };

        location.address = "Gdansk, Poland";

        weather = {
          enabled = true;
          unit = "celsius";
        };

        shell = {
          time_format = "{:%a, %d %b %Y %H:%M}";
          font_family = "CommitMono Nerd Font";
          clipboard_enabled = true;
          clipboard_history_max_entries = 20;
        };

        bar.main = {
          position = "top";
          margin_edge = 8;
          margin_ends = 10;
          radius = 12;
          shadow = true;
          scale = 0.92;

          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "clock"
            "clock_weather_gap"
            "weather"
          ];
          end = [
            "mic"
            "sysmon_gap"
            "volume"
            "sysmon_gap"
            "cpu"
            "sysmon_gap"
            "memory"
            "sysmon_gap"
            "battery"
            "actions_group_gap"
            "clipboard"
            "notifications"
            "session"
          ];
        };

        widget = {
          clock = {
            format = "{:%a, %d %b %Y %H:%M}";
          };
          clock_weather_gap = {
            type = "spacer";
            length = 20;
          };
          sysmon_gap = {
            type = "spacer";
            length = 10;
          };
          actions_group_gap = {
            type = "spacer";
            length = 16;
          };
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
