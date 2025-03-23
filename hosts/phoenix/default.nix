{ inputs, ... }:
let 
foo = "bar";
in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    # inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    ../../modules/common
    ../../modules/nixos
    ./.config.nix # TODO: get rid of this
    ./.passwd.nix # TODO: get rid of this
    ./containers.nix
    ./traefik.nix
    ./hardware.nix
    ({ lib, pkgs, ...}: {
      hostname = "phoenix";

      boot.loader.systemd-boot.enable = true;

      disk.vm.enable = true;
      disk.vm.device = "/dev/vda";

      services.openssh.enable = true;
      services.qemuGuest.enable = true;

      # TODO: deploy remotely as non-root user?

      # docker.enable = true; # TODO: no

      fileSystems."/mnt/shares" = {
        device = "shares";
        fsType = "virtiofs";
      };

      # TODO: denote as VPN DNS
      # services.unbound = {
      #   enable = true;
      #   stateDir = "only";
      #   # directory = "/mnt/shares/appdata/bind";
      #   # configFile = "/mnt/shares/appdata/named/conf.local";
      # };

      environment.systemPackages = [pkgs.dig];

      networking.firewall.allowedTCPPorts = [ 53 ];
      networking.firewall.allowedUDPPorts = [ 53 ];

      # TODO: move to container
      services.unbound = {
        enable = true;
        resolveLocalQueries = false;
        settings.server.interface = [
          # "10.8.8.10"
          # "127.0.0.1"
          "tailscale0"
        ];
        settings.server.access-control = [
          # "10.8.0.0/16 allow"
          # "127.0.0.0/8 allow"
          "100.64.0.0/10 allow"
        ];
      };

      services.tailscale = {
        enable = true;
        openFirewall = true;
      };
    })
  ];
}
