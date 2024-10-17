{ config, lib, pkgs, ... }:

{
  options = {
    slack = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.slack.enable {
    environment.systemPackages = [ pkgs.slack ];
    unfreePackages = [ "slack" ];
  };
}