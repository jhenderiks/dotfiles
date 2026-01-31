{ inputs, ... }:

inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    # inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
    # inputs.jovian-nixos.nixosModules.default
    ../../modules/common
    ../../modules/nixos
    ./.config.nix # TODO: get rid of this
    ./.passwd.nix # TODO: get rid of this
    ./hardware.nix
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        hostname = "aether";

        boot.loader.systemd-boot.enable = true;

        disk.vm.enable = true;
        disk.vm.device = "/dev/vda";
        # TODO: impermanence for VMs?

        # TODO: bookmarked guide to make streaming great

        services.qemuGuest.enable = true;

        # TODO: deploy remotely as non-root user?

        fileSystems."/mnt/games" = {
          device = "games";
          fsType = "virtiofs";
        };

        # gemstreming shit

        # gnome.enable = true;
        kde.enable = true;

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        environment.systemPackages = with pkgs; [
          kitty
          konsole
          ungoogled-chromium
          # lutris
        ];

        # jovian.steam = {
        #   enable = true;
        #   autoStart = true;
        #   # desktopSession = "gnome";
        #   desktopSession = "gamescope-wayland";
        #   user = config.user.name;
        # };

        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
        };

        # services.pulseaudio.enable = true;

        services = {
          displayManager.autoLogin = {
            enable = true;
            user = config.user.name;
          };

          sunshine = {
            enable = true;
            autoStart = true;
            capSysAdmin = true;
            openFirewall = true;
          };

          tailscale = {
            enable = true;
            openFirewall = true;
          };

          # udev.extraRules = ''
          #   ACTION=="add", SUBSYSTEM=="drm", TAG+="systemd"
          # '';

          # xserver.videoDrivers = [ "amdgpu" ];
        };

        # systemd.user.services.sunshine = {
        #   # requires = [ "dev-dri-renderD128.device" ];
        #   # aliases = [ "display-manager.service" ];
        #   wantedBy = lib.mkIf config.services.sunshine.autoStart [ "gamescope-session.service" "gamescope.service" ];
        #   partOf = [ "gamescope-session.service" "gamescope.service" ];
        #   wants = [ "gamescope-session.service" "gamescope.service" ];
        #   after = [ "gamescope-session.service" "gamescope.service" ];
        # };

        unfreePackages = [
          "steam"
          # "steam-jupiter-unwrapped"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
          # "steamdeck-hw-theme"
        ];
      }
    )
  ];
}
