{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    discord = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.discord.enable {
    macos.homebrew.casks = [ "discord" ];
    nixos.environment.systemPackages = [ pkgs.discord ];
    unfreePackages = [ "discord" ];
  };
}
