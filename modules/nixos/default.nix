{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}:

let
  identityPath =
    if config.disk.main.impermanence.enable then
      "${config.disk.main.impermanence.dir}/etc/ssh/ssh_host_ed25519_key"
    else
      "/etc/ssh/ssh_host_ed25519_key";
  nixosConfig = builtins.mapAttrs (name: value: config.nixos.${name}) options.nixos;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./disk
    ./gnome.nix
    ./hyprland.nix
    ./kde.nix
    ./niri.nix
  ];

  options = with lib; {
    user.hashedPasswordFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = lib.mkMerge [
    nixosConfig
    {
      age.identityPaths = [ identityPath ];
      age.secrets.hashedPassword.file = ../../hosts/${config.hostname}/password.age;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.loader.systemd-boot.configurationLimit = 16;

      environment.systemPackages = [ pkgs.moonlight-qt ];

      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = true;

      hardware.enableRedistributableFirmware = lib.mkDefault true;

      home-manager.sharedModules = [
        {
          xdg = {
            # TODO: try this in macos
            enable = true;

            userDirs = {
              enable = true;
              createDirectories = true;
              desktop = "$HOME/desktop";
              documents = "$HOME/docs";
              download = "$HOME/downloads";
              music = "$HOME/media/music";
              pictures = "$HOME/media/images";
              publicShare = "$HOME/public";
              templates = "$HOME/templates";
              videos = "$HOME/media/videos";
              extraConfig = {
                XDG_DEV_DIR = "$HOME/dev";
              };
            };
          };
        }
      ];

      networking.networkmanager.enable = true;

      services.openssh.enable = true;
      services.printing.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/68489
      services.automatic-timezoned.enable = true;
      services.geoclue2.enableDemoAgent = lib.mkForce true;
      services.geoclue2.geoProviderUrl = "https://beacondb.net/v1/geolocate";

      user = {
        users = {
          isNormalUser = true;
          extraGroups = [
            "docker"
            "wheel"
          ];
          hashedPasswordFile = config.age.secrets.hashedPassword.path;
        };
      };

      users.mutableUsers = false;
    }
  ];
}
