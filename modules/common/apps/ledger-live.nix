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

      hardware.ledger.enable = true;
    };
  };
}
