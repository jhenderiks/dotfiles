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
    ./cleanup.nix
    ./disk
    ./gnome.nix
    ./handy.nix
    ./hyprland.nix
    ./kde.nix
    ./niri.nix
    ./wireguard.nix
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

      boot.kernelPackages = pkgs.linuxPackages_latest.extend (
        _: prev:
        let
          # These packages install modules manually, bypassing Kbuild's signing step.
          # Sign after stripping so the module aggregator can collect their certificates.
          signModules =
            package:
            package.overrideAttrs (old: {
              postFixup = (old.postFixup or "") + ''
                find "$out/lib/modules" -name '*.ko' \
                  -exec ${lib.getExe pkgs.buildPackages.kmodigest} {} \;
              '';
            });
        in
        {
          evdi = signModules prev.evdi;
          framework-laptop-kmod = signModules prev.framework-laptop-kmod;
        }
      );

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
              setSessionVariables = true;
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
                DEV = "$HOME/dev";
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
