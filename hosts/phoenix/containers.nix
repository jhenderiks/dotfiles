{ config, lib, pkgs, ...}:

let
  cfgDir = "/mnt/config";

  user = "somebody";
  group = "users";

  mountCfg = containerName: {
    hostPath = "/mnt/shares/appdata/${containerName}";
    mountPoint = cfgDir;
    isReadOnly = false;
  };

  _mountShare = isReadOnly: share: {
    hostPath = "/mnt/shares/${share}";
    mountPoint = "/mnt/${share}";
    inherit isReadOnly;
  };

  mountShare = _mountShare false;
  mountShareReadOnly = _mountShare true;

  router = service: {
    entryPoints = [ "http" ];
    inherit service;
    rule = "Host(`${service}.${config.phoenix.domain}`)";
  };

  service = protocol: ip: port: {
    loadBalancer = {
      servers = [
        { url = "${protocol}\://${ip}:${toString port}"; }
      ];
    };
  };

  mkContainer = ip: cfg: {
    containers.${cfg.name} = {
      autoStart = true;

      bindMounts = builtins.listToAttrs (map (value: {
        name = value.mountPoint;
        inherit value;
      }) ([ (mountCfg cfg.name) ] ++ cfg.mounts));

      hostBridge = "br0";

      localAddress = "${ip}/16";

      privateNetwork = true;

      config = {
        networking = {
          defaultGateway = "172.16.0.1";

          # enableIPv6 = false;
          # firewall.enable = false; # TODO: need?
          hostName = cfg.name;
          # networkmanager.enable = true;

          nameservers = config.networking.nameservers;
        };

        nixpkgs = if (builtins.hasAttr "nixpkgs" cfg)
          then cfg.nixpkgs
          else {};

        services = cfg.services;

        system.stateVersion = config.system.stateVersion;

        users.users.${user} = {
          uid = 99;
          inherit group;
        };
      };
    };

    services.traefik.dynamicConfigOptions.http = {
      routers.${cfg.name} = router cfg.name;
      services.${cfg.name} = service "http" ip cfg.port;
    };
  };

  # TODO: put appdata in syncthing and sync to cloud (re-do cloud server using nixos, put tailscale on everything)

  containers = [
    {
      name = "sonarr";
      port = 8989;

      mounts = [
        (mountShare "downloads")
        (mountShare "tv")
      ];

      nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-6.0.428"
      ];

      services.sonarr = {
        enable = true;
        inherit user;
        inherit group;
        dataDir = cfgDir; # serviceCfgDir "sonarr";
        openFirewall = true; # TODO: need this?
      };
    }
    {
      name = "sonarr-anime";
      port = 8989;

      mounts = [
        (mountShare "downloads")
        (mountShare "anime")
      ];

      nixpkgs.config.permittedInsecurePackages = [
        "aspnetcore-runtime-6.0.36"
        "dotnet-sdk-6.0.428"
      ];

      services.sonarr = {
        enable = true;
        inherit user;
        inherit group;
        dataDir = cfgDir; # serviceCfgDir "sonarr";
        openFirewall = true; # TODO: need this?
      };
    }
  ];

  containersCfg = lib.mkMerge (
    lib.lists.imap1 (
      i: container: mkContainer "172.16.0.${toString (100 + i)}" container
    ) containers
  );

in lib.mkMerge [
  {
    networking = {
      bridges.br0.interfaces = [];

      # enableIPv6 = false;

      # firewall.enable = false; # TODO: make br0 safe instead

      interfaces.br0 = {
        ipv4.addresses = [{
          address = "172.16.0.1";
          prefixLength = 16;
        }];
      };

      nat = {
        enable = true;
        externalInterface = "enp2s0";
        internalInterfaces = [ "br0" ];
      };
    };
  }
  containersCfg
]
