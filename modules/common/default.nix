{ config, inputs, ... }:

{
  imports = [
    ./apps
    ./dev
    ./services
    ./shell
    ./fonts.nix
    ./options.nix
  ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.settings.experimental-features = "nix-command flakes";

  user.home-manager = {
    imports = [
      inputs.catppuccin.homeModules.catppuccin
    ];

    catppuccin.enable = true;

    home.stateVersion = config.system.stateVersion;
  };
}
