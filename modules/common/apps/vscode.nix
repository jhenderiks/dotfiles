{ config, lib, pkgs, ... }:

{
  options = {
    vscode = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.vscode.enable {
    _macos.homebrew.casks = [ "visual-studio-code" ];

    _nixos.environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
        ];
      })
    ];

    _unfreePackages = [
      "vscode"
      "vscode-with-extensions"
    ];
  };
}
