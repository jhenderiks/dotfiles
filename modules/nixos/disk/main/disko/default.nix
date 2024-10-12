{ config, lib, ... }:

{
  config = lib.mkIf config.disk.main.enable {
    disko.devices.disk.main = {
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
}