{ config, lib, pkgs, ... }:

{
  options = {
    postman = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.postman.enable {
    environment.systemPackages = [ pkgs.postman ];
    unfreePackages = [ "postman" ];
  };
}
