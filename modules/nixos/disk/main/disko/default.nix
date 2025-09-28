{ config, lib, ... }:

{
  config = lib.mkIf config.disk.main.enable {
    disko.devices.disk = {
      main = {
        type = "disk";
        device = config.disk.main.device;
        content = {
          type = "gpt";
          partitions = if config.disk.main.encrypted
            then import ./luks.nix
            else import ./root.nix;
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";
        
        datasets = {
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
          state = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/state";
          };
        };
      };
    };
  };
}
