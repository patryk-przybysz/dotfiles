{
  config,
  lib,
  pkgs,
  inputs,
  perSystem,
  ...
}:
let
  cfg = config.my.home.noctalia;
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpaperFile = "${wallpaperDir}/sylas.jpg";

  screenToolkitPackages = with pkgs; [
    hyprpicker
    grim
    slurp
    wl-clipboard
    imagemagick
    (tesseract5.override {
      enableLanguages = [
        "eng"
        "pol"
      ];
    })
  ];

  enabledPlugins = [
    "alexander/screen-toolkit"
  ]
  ++ lib.optionals config.my.home.mcsr.enable [
    "radimous/prismlauncher-instances"
  ];
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  options.my.home.noctalia.enable = lib.mkEnableOption "Noctalia desktop shell";

  config = lib.mkIf cfg.enable {
    home.packages = screenToolkitPackages ++ [ pkgs.libnotify ];

    programs.noctalia = {
      enable = true;
      package = perSystem.noctalia.default;

      settings = {
        notification = {
          enable_daemon = true;
          show_app_name = true;
          show_actions = true;
        };

        osd = {
          kinds = {
            media = false;
          };
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

        bar = {
          main = {
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
              "media"
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
              "tray"
              "session"
            ];
          };
        };

        dock = {
          enabled = true;
          position = "bottom";
          margin_edge = 8;
          margin_ends = 10;
          radius = 12;
          background_opacity = 0.88;
          shadow = false;
          auto_hide = false;
          smart_auto_hide = true;
          reserve_space = false;
          show_running = true;
          item_spacing = 6;
          icon_size = 44;
        };

        plugins.enabled = enabledPlugins;

        plugin_settings."alexander/screen-toolkit" = {
          "selected-ocr-lang" = "eng+pol";
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
          media = {
            type = "media";
            hide_when_no_media = true;
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
