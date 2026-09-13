{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.niri;

  binds = {
    # Focus
    "A".focus-column-left = { };
    "D".focus-column-right = { };
    "Left".focus-column-left = { };
    "Right".focus-column-right = { };
    "Up".focus-window-up = { };
    "Down".focus-window-down = { };

    # Move window
    "Shift+Left".move-column-left = { };
    "Shift+Right".move-column-right = { };

    # Resize
    "U".set-column-width = "-10%";
    "P".set-column-width = "+10%";
    "O".set-window-height = "+10%";
    "I".set-window-height = "-10%";
    "Ctrl+F".expand-column-to-available-width = { };
    "Ctrl+P".switch-preset-column-width = { };
    "C".center-column = { };

    # Layout / window state
    "V".toggle-column-tabbed-display = { };
    "Ctrl+Space".switch-focus-between-floating-and-tiling = { };
    "Shift+Space".toggle-window-floating = { };
    "T".maximize-column = { };
    "F".fullscreen-window = { };
    "Q".close-window = { };

    # Launchers
    "Space".spawn = [
      "noctalia"
      "msg"
      "panel-toggle"
      "launcher"
    ];
    "N".spawn = [
      "noctalia"
      "msg"
      "panel-toggle"
      "control-center"
      "notifications"
    ];
    "X".spawn = [ "alacritty" ];
    "B".spawn = [ "microsoft-edge" ];
    "E".spawn = [ "thunar" ];

    # Session / help
    "Shift+E".quit = { };
    "Shift+Slash".show-hotkey-overlay = { };
  };

  workspaceFocusBinds = builtins.listToAttrs (
    map (n: {
      name = "Mod+${toString n}";
      value.action.focus-workspace = n;
    }) (lib.range 1 9)
  );

  workspaceMoveBinds = builtins.listToAttrs (
    map (n: {
      name = "Mod+Shift+${toString n}";
      value.action.move-window-to-workspace = n;
    }) (lib.range 1 9)
  );

  columnToWorkspaceBinds = builtins.listToAttrs (
    map (n: {
      name = "Mod+Ctrl+${toString n}";
      value.action.move-column-to-workspace = n;
    }) (lib.range 1 9)
  );

  # sodiboo/niri-flake layer-rules omit background-effect; append raw KDL after HM render.
  noctaliaLayerRules = ''
    // Noctalia: no compositor blur on bar surfaces — only widget pills show fill.
    layer-rule {
      match namespace="^noctalia-bar-[^\"]+$"
      background-effect {
        blur false
      }
    }

    layer-rule {
      match namespace="^noctalia-(notification|dock|panel|attached-panel|osd)$"
      background-effect {
        xray false
      }
    }
  '';
in
{
  imports = [ inputs.niri.homeModules.niri ];

  options.my.home.niri.enable = lib.mkEnableOption "niri scrollable-tiling compositor";

  config = lib.mkIf cfg.enable (
    let
      niriSettings = {
        prefer-no-csd = true;

        hotkey-overlay.skip-at-startup = true;

        input = {
          keyboard.xkb.layout = "pl";
          mouse = {
            accel-profile = "flat";
            accel-speed = -0.9375;
          };
        };

        gestures.hot-corners.enable = false;

        layout = {
          gaps = 10;
          border = {
            enable = true;
            width = 2;
            active.color = "#b4befe99";
            inactive.color = "#a1a1a166";
          };
          focus-ring.enable = false;
          # Let each app pick its initial width (niri default is 0.5 = half screen).
          default-column-width = { };
        };

        spawn-at-startup = [
          { command = [ "noctalia" ]; }
          { command = [ "xwayland-satellite" ]; }
        ];

        window-rules = [
          {
            matches = [ { } ];
            draw-border-with-background = false;
            geometry-corner-radius = {
              top-left = 10.0;
              top-right = 10.0;
              bottom-right = 10.0;
              bottom-left = 10.0;
            };
            clip-to-geometry = true;
          }
          {
            matches = [ { title = "[Pp]icture.in.[Pp]icture|Obraz w obrazie"; } ];
            open-floating = true;
          }
        ];

        binds =
          lib.mapAttrs' (suffix: action: {
            name = "Mod+${suffix}";
            value.action = action;
          }) binds
          // workspaceFocusBinds
          // workspaceMoveBinds
          // columnToWorkspaceBinds
          // {
            "Mod+WheelScrollUp" = {
              action.focus-workspace-up = { };
              cooldown-ms = 150;
            };
            "Mod+WheelScrollDown" = {
              action.focus-workspace-down = { };
              cooldown-ms = 150;
            };
            # Acer Nitro/Predator Sense key (hwdb maps scancode 0xf5 → XF86Launch1)
            "XF86Launch1".action.spawn = [ "DAMX" ];
            "XF86AudioRaiseVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%+"
            ];
            "XF86AudioLowerVolume".action.spawn = [
              "wpctl"
              "set-volume"
              "@DEFAULT_AUDIO_SINK@"
              "5%-"
            ];
            "XF86AudioMute".action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SINK@"
              "toggle"
            ];
            "XF86AudioMicMute".action.spawn = [
              "wpctl"
              "set-mute"
              "@DEFAULT_AUDIO_SOURCE@"
              "toggle"
            ];
            "XF86AudioPlay".action.spawn = [
              "playerctl"
              "play-pause"
            ];
            "XF86AudioNext".action.spawn = [
              "playerctl"
              "next"
            ];
            "XF86AudioPrev".action.spawn = [
              "playerctl"
              "previous"
            ];
            "XF86AudioStop".action.spawn = [
              "playerctl"
              "stop"
            ];

            "XF86Explorer".action.spawn = [ "thunar" ];
            "XF86HomePage".action.spawn = [ "microsoft-edge" ];

            "Print".action.screenshot = { };
            "Shift+Print".action.screenshot-window = { };
            "Ctrl+Print".action.screenshot-screen = { };
            "Mod+Shift+S".action.screenshot = { };
            "Mod+Tab".action.toggle-overview = { };

            "Mod+V".action.spawn = [
              "noctalia"
              "msg"
              "panel-toggle"
              "clipboard"
            ];
            "Mod+Shift+C".action.spawn = [
              "noctalia"
              "msg"
              "plugin"
              "alexander/screen-toolkit:service"
              "all"
              "colorPicker"
            ];
            "Mod+Shift+T".action.spawn = [
              "noctalia"
              "msg"
              "plugin"
              "alexander/screen-toolkit:service"
              "all"
              "ocr"
            ];
          };
      };
    in
    {
      home.packages = [
        pkgs.xwayland-satellite
        pkgs.playerctl
      ];

      programs.niri = {
        package = pkgs.niri;
        settings = niriSettings;
        config =
          (lib.evalModules {
            modules = [
              inputs.niri.lib.internal.settings-module
              { programs.niri.settings = niriSettings; }
            ];
          }).config.programs.niri.finalConfig
          + "\n"
          + noctaliaLayerRules;
      };
    }
  );
}
