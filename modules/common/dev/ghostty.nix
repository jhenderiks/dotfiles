{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    ghostty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.ghostty.enable {
    environment.systemPackages = [ pkgs.ghostty ];

    home-manager.sharedModules = [
      {
        programs.ghostty = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            font-family = lib.mkForce config.font.monospace;
          };
        };
      }
    ];
  };
}
