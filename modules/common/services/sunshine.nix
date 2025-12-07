{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = with lib; {
    sunshine = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.sunshine.enable {
    nixos = {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
    };
  };
}
