{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.nixos.mcsr.tmpfs;
  inherit (lib) types;

  userCfg = config.users.users.${cfg.user};
  # isNormalUser without an explicit uid leaves .uid as null at eval time
  # (attr exists, so `uid or 1000` does not help).
  uid = toString (if userCfg.uid == null then 1000 else userCfg.uid);
  gid = toString config.users.groups.${userCfg.group}.gid;

  instanceNames = lib.attrNames cfg.instances;

  # Escape a path for embedding inside a single-quoted bash string.
  bashEscape = s: lib.replaceStrings [ "'" ] [ "'\\''" ] s;

  setupScript = pkgs.writeShellScript "mc-tmpfs-setup" ''
    set -euo pipefail
    maps_dir='${bashEscape cfg.practiceMapsDir}'
    mount_point='${bashEscape cfg.mountPoint}'

    ${lib.concatMapStringsSep "\n" (name: ''
      mkdir -p "$mount_point/${bashEscape name}"
    '') instanceNames}

    if [ -d "$maps_dir" ]; then
      shopt -s nullglob
      for map in "$maps_dir"/Z*; do
        [ -e "$map" ] || continue
        base="$(basename "$map")"
        ${lib.concatMapStringsSep "\n" (name: ''
          ln -sfn "$map" "$mount_point/${bashEscape name}/$base"
        '') instanceNames}
      done
    fi

    ${lib.concatMapStringsSep "\n" (
      name:
      let
        inst = cfg.instances.${name};
        saves = bashEscape inst.savesPath;
        target = bashEscape "${cfg.mountPoint}/${name}";
      in
      ''
        saves='${saves}'
        target='${target}'
        mkdir -p "$(dirname "$saves")"
        if [ -L "$saves" ]; then
          if [ "$(readlink "$saves")" != "$target" ]; then
            ln -sfn "$target" "$saves"
          fi
        elif [ -e "$saves" ]; then
          echo "mc-tmpfs-setup: leaving existing path alone (migrate manually): $saves" >&2
        else
          ln -s "$target" "$saves"
        fi
      ''
    ) instanceNames}
  '';

  cleanupScript = pkgs.writeShellScript "mc-tmpfs-cleanup" ''
    set -euo pipefail
    keep=${toString cfg.keepWorlds}
    ${lib.concatMapStringsSep "\n" (name: ''
      dir='${bashEscape "${cfg.mountPoint}/${name}"}'
      if [ -d "$dir" ]; then
        # Preserve practice maps (Z*) and the newest $keep worlds for verification.
        ls -t1 --ignore='Z*' "$dir" 2>/dev/null | tail -n +"$((keep + 1))" | while IFS= read -r save; do
          rm -rf "$dir/$save"
        done
      fi
    '') instanceNames}
  '';
in
{
  options.my.nixos.mcsr.tmpfs = {
    enable = lib.mkEnableOption "MCSR world tmpfs (dedicated mount, setup + cleanup timer)";

    user = lib.mkOption {
      type = types.str;
      default = "patryk";
      description = "User that owns the tmpfs mount and runs setup/cleanup.";
    };

    mountPoint = lib.mkOption {
      type = types.str;
      default = "/home/patryk/mcsr/tmpfs";
      description = "Dedicated tmpfs mount for Minecraft saves (not all of /tmp).";
    };

    size = lib.mkOption {
      type = types.str;
      default = "4G";
      description = "tmpfs size ceiling (not preallocated).";
    };

    practiceMapsDir = lib.mkOption {
      type = types.str;
      default = "/home/patryk/mcsr/practice-maps";
      description = "Persistent practice maps; entries matching Z* are symlinked into each instance tmpfs dir on boot.";
    };

    keepWorlds = lib.mkOption {
      type = types.ints.positive;
      default = 1000;
      description = "Newest non-Z* worlds to keep per instance (SeedQueue verification-friendly).";
    };

    cleanupInterval = lib.mkOption {
      type = types.ints.positive;
      default = 300;
      description = "Seconds between cleanup runs.";
    };

    instances = lib.mkOption {
      type = types.attrsOf (
        types.submodule (_: {
          options.savesPath = lib.mkOption {
            type = types.str;
            description = "Absolute path to the instance saves directory (becomes a symlink into tmpfs).";
          };
        })
      );
      default = { };
      example = {
        RSG.savesPath = "/home/patryk/.local/share/PrismLauncher/instances/1.16.1 RSG/minecraft/saves";
      };
      description = "Attr names are tmpfs subdirectories; values point at Prism/MultiMC saves paths.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.instances != { };
        message = "my.nixos.mcsr.tmpfs.instances must list at least one instance.";
      }
      {
        assertion = config.users.users ? ${cfg.user};
        message = "my.nixos.mcsr.tmpfs.user (${cfg.user}) does not exist.";
      }
    ];

    # Dedicated mount — avoids boot.tmp.useTmpfs (which puts all of /tmp in RAM
    # and can OOM nix builds). Pattern from flammablebunny/flake.
    fileSystems.${cfg.mountPoint} = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "size=${cfg.size}"
        "mode=0755"
        "uid=${uid}"
        "gid=${gid}"
      ];
    };

    systemd = {
      tmpfiles.rules =
        let
          # Only create dirs on the real filesystem. Instance dirs under the
          # tmpfs mount are created by mc-tmpfs-setup after the mount is up.
          parents = lib.unique [
            (builtins.dirOf cfg.mountPoint)
            cfg.practiceMapsDir
          ];
        in
        map (dir: "d ${dir} 0755 ${cfg.user} ${userCfg.group} -") parents;

      services.mc-tmpfs-setup = {
        description = "MCSR tmpfs dirs, practice-map links, and saves symlinks";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          RemainAfterExit = true;
          RequiresMountsFor = [ cfg.mountPoint ];
          ExecStart = setupScript;
        };
      };

      services.mc-tmpfs-cleanup = {
        description = "MCSR tmpfs world cleanup";
        after = [ "mc-tmpfs-setup.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          RequiresMountsFor = [ cfg.mountPoint ];
          ExecStart = cleanupScript;
        };
      };

      timers.mc-tmpfs-cleanup = {
        description = "MCSR tmpfs world cleanup timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "30s";
          OnUnitActiveSec = "${toString cfg.cleanupInterval}s";
          AccuracySec = "5s";
          Unit = "mc-tmpfs-cleanup.service";
        };
      };
    };
  };
}
