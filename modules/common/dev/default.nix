{ config, lib, pkgs, ... }:

{
  imports = [
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
    docker.enable = true;
    kitty.enable = true;
    vscode.enable = true;
  };
}
