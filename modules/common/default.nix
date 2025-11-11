{ config, inputs, ... }:

{
  imports = [
    ./apps
    ./dev
    ./services
    ./shell
    ./theme.nix
    ./options.nix
  ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  nix.settings.experimental-features = "nix-command flakes";

  home-manager.sharedModules = [
    {
      home.stateVersion = config.system.stateVersion;
    }
  ];
}
