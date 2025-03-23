{ config, lib, pkgs, ...}:

let
  router = service: {
    entryPoints = [ "http" ];
    inherit service;
    rule = "Host(`${service}.${config.phoenix.domain}`)";
  };

  service = protocol: ip: port: {
    loadBalancer = {
      servers = [
        { url = "${protocol}\://${ip}:${port}"; }
      ];
    };
  };
in {
  options.phoenix = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = null;
    };

    ip = lib.mkOption {
      type = lib.types.str;
      default = null;
    };

    aetherIp = lib.mkOption {
      type = lib.types.str;
      default = null;
    };

    unraidIp = lib.mkOption {
      type = lib.types.str;
      default = null;
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 ];

    services = {
      traefik = {
        enable = true;
        dataDir = "/mnt/shares/appdata/traefik";
        dynamicConfigOptions = {
          http = {
            routers = {
              sunshine = router "sunshine";
              unraid = router "unraid";
            };
            services = {
              sunshine = service "https" config.phoenix.aetherIp "47990";
              unraid = service "http" config.phoenix.unraidIp "8080"; # TODO: 80
            };
          };
        };
        staticConfigOptions = {
          accessLog = {}; # TODO: no?
          api = { insecure = true; }; # TODO: need this?
          entryPoints = {
            http = {
              address = ":80";
            };
          };
          log = { level = "DEBUG"; }; # TODO: INFO
          serversTransport = {
            insecureSkipVerify = true; # TODO: no tho?
          };
        };
      };
    };
  };
}
