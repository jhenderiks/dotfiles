{ config, inputs, lib, pkgs, ... }:

# TODO: if catppuccin.enable

let
  open-vsx = inputs.nix-vscode-extensions.extensions.${pkgs.system}.open-vsx;
  vscode-marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
  options = with lib; {
    cursor = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.cursor.enable {
    config.vscode.enable = true;
    config.vscode.package = pkgs.code-cursor;
  };
}
