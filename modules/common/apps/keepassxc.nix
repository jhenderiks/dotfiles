{ config, lib, pkgs, ... }:

{
  options = {
    keepassxc = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.keepassxc.enable {
    environment.systemPackages = [ pkgs.keepassxc ];

    chromium.extensions = [ "oboonakemofpalcgghocfoadofidjkkk" ];
  };
}
