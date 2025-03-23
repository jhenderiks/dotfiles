{ config, options, lib, ... }:

let
  cfg = config.disk.vm;
  ifDisabled = val: if cfg.enable then null else val; 
in {
  options = with lib; {
    disk.vm = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      device = mkOption {
        type = types.str;
        default = ifDisabled "";
      };
    };
  };

  config = lib.mkIf config.disk.vm.enable {
    disko.devices.disk.vm = {
      type = "disk";
      device = config.disk.vm.device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          swap = {
            size = "1G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
