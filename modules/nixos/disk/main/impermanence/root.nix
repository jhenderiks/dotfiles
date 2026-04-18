{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.disk.main.impermanence.enable {
    boot.initrd.postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) (
      lib.mkAfter ''
        MNT=/mnt
        SUBVOL=root
        SUBVOL_PATH="$MNT/$SUBVOL"

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "$MNT/$i"
          done
          btrfs subvolume delete "$1"
        }

        mkdir -p "$MNT"
        mount ${config.fileSystems."/".device} "$MNT"

        delete_subvolume_recursively "$SUBVOL_PATH"

        btrfs subvolume create "$SUBVOL_PATH"
        umount "$MNT"
      ''
    );

    boot.initrd.systemd.services.rollback-root = lib.mkIf config.boot.initrd.systemd.enable {
      description = "Reset Btrfs root subvolume for impermanence";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      after = [
        "systemd-udev-settle.service"
      ]
      ++ lib.optionals config.disk.main.encrypted [ "cryptsetup.target" ];
      wants = [
        "systemd-udev-settle.service"
      ]
      ++ lib.optionals config.disk.main.encrypted [ "cryptsetup.target" ];
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      path = with pkgs; [
        btrfs-progs
        coreutils
        util-linux
      ];
      script = ''
        MNT=/mnt
        SUBVOL=root
        SUBVOL_PATH="$MNT/$SUBVOL"

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "$MNT/$i"
          done
          btrfs subvolume delete "$1"
        }

        mkdir -p "$MNT"
        mount ${config.fileSystems."/".device} "$MNT"

        delete_subvolume_recursively "$SUBVOL_PATH"

        btrfs subvolume create "$SUBVOL_PATH"
        umount "$MNT"
      '';
    };

    environment.persistence.${config.disk.main.impermanence.dir} = {
      directories = [
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/etc/ssh"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
      files = [
        "/etc/machine-id"
        # {
        #   file = "/var/keys/secret_file";
        #   parentDirectory = {
        #     mode = "u=rwx,g=,o=";
        #   };
        # }
      ];
    };
  };
}
