{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.home.niri;

  # suffix -> action; all bound on Alt
  binds = {
    # Focus
    "H".focus-column-left = { };
    "L".focus-column-right = { };
    "K".focus-window-up = { };
    "J".focus-window-down = { };
    "Left".focus-column-left = { };
    "Right".focus-column-right = { };
    "Up".focus-window-up = { };
    "Down".focus-window-down = { };

    # Move window
    "Shift+H".move-column-left = { };
    "Shift+L".move-column-right = { };
    "Shift+K".move-window-up = { };
    "Shift+J".move-window-down = { };
    "Shift+Left".move-column-left = { };
    "Shift+Right".move-column-right = { };
    # Stack/unstack: GlazeWM move down/up joined windows into the same column.
    # Down pulls the window to the right into this column; Up joins this window into the column on the left.
    "Shift+Up".consume-or-expel-window-left = { };
    "Shift+Down".consume-window-into-column = { };

    # Consume/expel windows into/out of columns (niri's core stacking mechanic)
    "Comma".consume-window-into-column = { };
    "Period".expel-window-from-column = { };

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
    "G".toggle-overview = { };

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
    "E".spawn = [ "dolphin" ];

    # Workspaces
    "S".focus-workspace-down = { };
    "A".focus-workspace-up = { };
    "D".focus-workspace-previous = { };

    # Move workspace between monitors
    "Shift+A".move-workspace-to-monitor-left = { };
    "Shift+F".move-workspace-to-monitor-right = { };
    "Shift+D".move-workspace-to-monitor-up = { };
    "Shift+S".move-workspace-to-monitor-down = { };

    # Focus other monitors
    "Ctrl+H".focus-monitor-left = { };
    "Ctrl+L".focus-monitor-right = { };
    "Ctrl+K".focus-monitor-up = { };
    "Ctrl+J".focus-monitor-down = { };

    # Session / help
    "Shift+E".quit = { };
    "Shift+Slash".show-hotkey-overlay = { };
  };

  workspaceFocusBinds = builtins.listToAttrs (
    map (n: {
      name = "Alt+${toString n}";
      value.action.focus-workspace = n;
    }) (lib.range 1 9)
  );

  workspaceMoveBinds = builtins.listToAttrs (
    map (n: {
      name = "Alt+Shift+${toString n}";
      value.action.move-window-to-workspace = n;
    }) (lib.range 1 9)
  );

  columnToWorkspaceBinds = builtins.listToAttrs (
    map (n: {
      name = "Alt+Ctrl+${toString n}";
      value.action.move-column-to-workspace = n;
    }) (lib.range 1 9)
  );
in
{
  imports = [ inputs.niri.homeModules.niri ];

  options.my.home.niri.enable = lib.mkEnableOption "niri scrollable-tiling compositor";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.xwayland-satellite ];

    programs.niri.package = pkgs.niri;

    programs.niri.settings = {
      prefer-no-csd = true;

      input = {
        keyboard.xkb.layout = "pl";
        mouse = {
          accel-profile = "flat";
          accel-speed = 0.0;
        };
      };

      gestures.hot-corners.enable = false;

      layout = {
        gaps = 10;
        # GlazeWM window_effects: focused #b4befe, other_windows #a1a1a1
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
          name = "Alt+${suffix}";
          value.action = action;
        }) binds
        // workspaceFocusBinds
        // workspaceMoveBinds
        // columnToWorkspaceBinds
        // {
          # Media keys
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

          "Print".action.screenshot = { };
          "Shift+Print".action.screenshot-window = { };
          "Ctrl+Print".action.screenshot-screen = { };
        };
    };
  };
}
