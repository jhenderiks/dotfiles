{
  config,
  lib,
  pkgs,
  ...
}:

let
  homeDir = "${config.user.homeBase}/${config.user.name}";
in
{
  options.cleanup.enable = lib.mkEnableOption "automatic disk cleanup";

  config = lib.mkIf config.cleanup.enable {
    nix.gc = {
      automatic = true;
      dates = "Sun 03:00";
      options = "--delete-older-than 30d";
    };

    systemd.services.docker-build-cache-prune = lib.mkIf config.docker.enable {
      description = "Prune old Docker build cache";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.concatStringsSep " " [
          "${config.virtualisation.docker.package}/bin/docker"
          "builder"
          "prune"
          "--all"
          "--force"
          "--filter"
          "until=720h"
        ];
      };
    };

    systemd.timers.docker-build-cache-prune = lib.mkIf config.docker.enable {
      description = "Periodically prune old Docker build cache";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "Sun 04:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
    };

    systemd.services.bun-cache-prune = {
      description = "Clear the Bun package cache";

      serviceConfig = {
        Type = "oneshot";
        User = config.user.name;
        ExecStart = "${pkgs.coreutils}/bin/rm -rf ${homeDir}/.cache/.bun";
      };
    };

    systemd.timers.bun-cache-prune = {
      description = "Periodically clear the Bun package cache";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "monthly";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };

    services.journald.extraConfig = ''
      SystemMaxUse=1G
      SystemKeepFree=10G
      MaxRetentionSec=30day
    '';
  };
}
