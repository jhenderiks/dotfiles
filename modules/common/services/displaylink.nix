{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = with lib; {
    displaylink = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.displaylink.enable {
    boot = {
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
      initrd.kernelModules = [ "evdi" ];
    };

    environment.systemPackages = [ pkgs.displaylink ];

    services.xserver.videoDrivers = [ "displaylink" ];

    systemd.services.dlm.wantedBy = [ "multi-user.target" ];

    unfreePackages = [ "displaylink" ];
  };
}
