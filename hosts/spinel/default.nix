{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    ../../modules/common
    ../../modules/nixos
    ./.config.nix # TODO: get rid of this
    ./.passwd.nix # TODO: get rid of this
    ./hardware.nix
    {
      hostname = "spinel";

      boot.loader.systemd-boot.enable = true;

      disk.main.enable = true;
      disk.main.device = "/dev/nvme0n1";
      disk.main.encrypted = true;
      disk.main.impermanence.enable = true;

      gnome.enable = true;
      hyprland.enable = true;
      # kde.enable = true;

      dev.enable = true;

      # TODO: nextdns

      # TODO: handle tailscale (and sudo) impermanence

      # TODO: move this
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      brave.enable = true;
      firefox.enable = true;
      keepassxc.enable = true;
      ledger-live.enable = true;
      nordvpn.enable = true; # TODO: switch to mullvad
      slack.enable = true;
      spotify.enable = true;
      steam.enable = true;
      syncthing.enable = true;
      telegram.enable = true;
      zoom.enable = true;
    }
  ];
}
