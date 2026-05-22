{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wireguard;
in
{
  options.wireguard = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    interface = mkOption {
      type = types.str;
      default = "wg0";
    };

    configFile = mkOption {
      type = types.str;
      default = "/etc/wireguard/${cfg.interface}.conf";
    };

    autoStart = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ pkgs.wireguard-tools ];

        networking.firewall.checkReversePath = false;

        systemd.services."wg-quick-${cfg.interface}" = {
          description = "WireGuard via wg-quick for ${cfg.interface}";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = lib.optionals cfg.autoStart [ "multi-user.target" ];
          path = with pkgs; [
            iproute2
            iptables
            openresolv
            procps
            wireguard-tools
          ];
          unitConfig.ConditionPathExists = cfg.configFile;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up ${lib.escapeShellArg cfg.configFile}";
            ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down ${lib.escapeShellArg cfg.configFile}";
          };
        };

        systemd.tmpfiles.rules = [
          "d /etc/wireguard 0700 root root -"
        ];
      }

      (lib.mkIf config.disk.main.impermanence.enable {
        environment.persistence.${config.disk.main.impermanence.dir}.directories = [
          {
            directory = "/etc/wireguard";
            mode = "0700";
          }
        ];
      })
    ]
  );
}
