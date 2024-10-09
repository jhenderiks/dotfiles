{ config, lib, pkgs, ... }:

{
  options = {
    slack = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.slack.enable {
    environment.systemPackages = with pkgs; [ slack ];

    cfg.unfreePackages = [ "slack" ];
  };
}