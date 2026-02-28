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

    services.xserver.videoDrivers = [ "modesetting" ];

    systemd.services.dlm = {
      description = "DisplayLink Manager Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];
      requires = [ "systemd-udevd.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
        Restart = "on-failure";
      };
    };

    unfreePackages = [ "displaylink" ];
  };
}
