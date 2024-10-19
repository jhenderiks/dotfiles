{ inputs, ... }:

{
  imports = [
    ./apps
    ./services
    ./shell
    ./fonts.nix
    ./options.nix
  ];

  config = {
    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;
    };

    nix.settings.experimental-features = "nix-command flakes";

    user.home-manager = {
      imports = [
        inputs.catppuccin.homeManagerModules.catppuccin
      ];

      catppuccin.enable = true;

      home.stateVersion = "24.11";
    };
  };
}
