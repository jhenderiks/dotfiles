{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./cursor.nix
    ./docker.nix
    ./kitty.nix
    ./vscode.nix
  ];

  options = with lib; {
    dev = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.dev.enable {
    cursor.enable = true;
    docker.enable = true;
    kitty.enable = true;
    # vscode.enable = true;

    environment.systemPackages = with pkgs; [
      nixfmt
      nixos-anywhere
    ];

    programs.nix-ld = {
      enable = true;

      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged programs
        # here, NOT in environment.systemPackages
      ];
    };
  };
}
