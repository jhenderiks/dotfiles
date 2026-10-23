{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.agenix.nixosModules.default
    inputs.eden.nixosModules.default
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    inputs.niri.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    ../../modules/common
    ../../modules/nixos
    ./hardware.nix
    (
      { config, pkgs, ... }:
      {
        system.stateVersion = "24.11";

        hostname = "spinel";

        boot.loader.systemd-boot.enable = true;
        boot.extraModprobeConfig = ''
          options snd-intel-dspcfg dsp_driver=3
        '';

        disk.main.enable = true;
        disk.main.device = "/dev/nvme0n1";
        disk.main.encrypted = true;
        disk.main.impermanence.enable = true;

        cleanup.enable = true;

        # gnome.enable = true;
        # hyprland.enable = true;
        # kde.enable = true;
        niri.enable = true;

        dev.enable = true;

        networking.resolvconf.extraConfig = ''
          search_domains='home.arpa'
        '';

        environment.systemPackages = with pkgs; [
          gnome-clocks
          simple-scan
          termdown
        ];

        hardware.sane = {
          enable = true;
          extraBackends = [ pkgs.sane-airscan ];
        };

        hardware.printers = {
          ensureDefaultPrinter = "Brother_HL-L2390DW";
          ensurePrinters = [
            {
              name = "Brother_HL-L2390DW";
              description = "Brother HL-L2390DW";
              deviceUri = "ipp://10.8.17.6:631/ipp/print";
              model = "everywhere";
            }
          ];
        };

        systemd.services.cups = {
          wants = [
            "avahi-daemon.service"
            "network-online.target"
          ];
          after = [
            "avahi-daemon.service"
            "network-online.target"
          ];
          unitConfig.StartLimitIntervalSec = 0;
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5s";
          };
        };

        users.users.${config.user.name}.extraGroups = [
          "lp"
          "scanner"
        ];

        programs.eden = {
          # enable = true;
          # enableCache = true;
        };

        security.sudo.extraConfig = ''
          Defaults lecture=never
        '';

        services.tailscale = {
          enable = true;
          openFirewall = true;
        };

        displaylink.enable = true;
        # Disabled while diagnosing stuck modifier state after lid/resume.
        # Handy's Linux shortcut backend uses raw input grabs, and its logs
        # correlate with the keyboard state getting wedged on this host.
        handy.enable = false;
        wireguard.enable = true;

        hardware.logitech.wireless = {
          enable = true;
          enableGraphical = true;
        };

        # TODO: nextdns

        activitywatch.enable = true;
        brave.enable = true;
        firefox.enable = true;
        gfn.enable = true;
        keepassxc.enable = true;
        ledger-live.enable = true;
        # nordvpn.enable = true; # TODO: switch to surfshark / proton
        slack.enable = true;
        spotify.enable = true;
        steam.enable = true;
        # sunshine.enable = true;
        syncthing.enable = true;
        telegram.enable = true;
        t3code.enable = true;
        zoom.enable = true;
      }
    )
  ];
}
