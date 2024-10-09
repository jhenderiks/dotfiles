{ config, lib, pkgs, ... }:

{
  options = {
    vscode = {
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.vscode.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      environment.systemPackages = with pkgs; [
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            bbenoist.nix
          ];
        })
      ];

      cfg.unfreePackages = [
        "vscode"
        "vscode-with-extensions"
      ];
    })

    (lib.mkIf pkgs.stdenv.isDarwin {
      homebrew.casks = [ "visual-studio-code" ];
    })
  ]);
}
