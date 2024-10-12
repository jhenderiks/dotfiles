{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    ../../modules/common
    ../../modules/nixos
    ./.config.nix
    ./.passwd.nix
    ./hardware.nix
    {
      _hostname = "spinel";

      boot.loader.systemd-boot.enable = true;

      disk.main.enable = true;
      disk.main.device = "/dev/nvme0n1";
      disk.main.encrypted = true;
      disk.main.impermanence.enable = true;

      gnome.enable = true;

      # bitwarden.enable = true;
      brave.enable = true;
      # chrome.enable = true;
      firefox.enable = true;
      keepassxc.enable = true;
      kitty.enable = true;
      ledger-live.enable = true;
      slack.enable = true;
      spotify.enable = true;
      syncthing.enable = true;
      vscode.enable = true;
      zoom.enable = true;
    }
  ];
}
