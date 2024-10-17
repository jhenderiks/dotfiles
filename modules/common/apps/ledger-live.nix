{ config, lib, pkgs, ... }:

{
  options = {
    ledger-live = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.ledger-live.enable {
    macos.homebrew.casks = [ "ledger-live" ];

    nixos = {
      environment.systemPackages = [ pkgs.ledger-live-desktop ];

      services.udev.extraRules = ''
        # HW.1, Nano
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c|2b7c|3b7c|4b7c", TAG+="uaccess", TAG+="udev-acl"

        # Blue, NanoS, Aramis, HW.2, Nano X, NanoSP, Stax, Ledger Test,
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", TAG+="uaccess", TAG+="udev-acl"

        # Same, but with hidraw-based library (instead of libusb)
        KERNEL=="hidraw*", ATTRS{idVendor}=="2c97", MODE="0666"
      '';
    };
  };
}
