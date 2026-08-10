{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.noctalia;
  system = pkgs.stdenv.hostPlatform.system;
  wallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  wallpaperFile = "${wallpaperDir}/sylas.jpg";

  # Taskbar pill gap is hardcoded to Style::spaceSm (8px); bump to spaceMd (12px).
  noctaliaPackage = inputs.noctalia.packages.${system}.default.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/shell/bar/widgets/taskbar_widget.cpp \
        --replace-fail 'const float tileGap = Style::spaceSm * m_contentScale;' \
                        'const float tileGap = Style::spaceMd * m_contentScale;'
    '';
  });

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
      package = noctaliaPackage;

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
          order = [
            "main"
            "tasks"
          ];

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
              "session"
            ];
          };

          tasks = {
            position = "bottom";
            margin_edge = 8;
            margin_ends = 10;
            background_opacity = 0;
            shadow = false;
            scale = 0.92;
            auto_hide = true;
            reserve_space = false;
            widget_spacing = 14;

            start = [ ];
            center = [ "taskbar" ];
            end = [ "group:tray" ];

            capsule_group = [
              {
                id = "tray";
                members = [ "tray" ];
                enabled = true;
                fill = "#1e1e2e";
                radius = 12;
                padding = 6;
              }
            ];
          };
        };

        plugins.enabled = enabledPlugins;

        plugin_settings."alexander/screen-toolkit" = {
          "selected-ocr-lang" = "eng+pol";
        };

        widget = {
          taskbar = {
            only_active_workspace = true;
            group_by_workspace = false;
            show_window_title = true;
            window_title_max_width = 100;
            show_active_indicator = true;
            capsule = true;
            capsule_fill = "#1e1e2e";
            capsule_radius = 12;
            capsule_padding = 6;
          };

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
