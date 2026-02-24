{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    mattermost = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.mattermost.enable {
    macos.homebrew.casks = [ "mattermost" ];
    nixos.environment.systemPackages = [ pkgs.mattermost ];
  };
}
