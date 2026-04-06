{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  open-vsx = inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.open-vsx;
  vscode-marketplace =
    inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace;
in
{
  options = with lib; {
    vscode = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.vscodium;
      };
    };
  };

  config = lib.mkIf config.vscode.enable {
    unfreePackages = [ "visual-studio-code" ];

    home-manager.sharedModules = [
      {
        programs.vscode = {
          enable = true;

          package = config.vscode.package;

          mutableExtensionsDir = false;

          profiles.default = {
            enableUpdateCheck = true;
            enableExtensionUpdateCheck = true;

            extensions = builtins.concatLists [
              (with open-vsx; [
                golang.go
                hashicorp.terraform
                jeanp413.open-remote-ssh
                jnoortheen.nix-ide
                ms-azuretools.vscode-docker
                ms-kubernetes-tools.vscode-kubernetes-tools
                redhat.vscode-yaml
              ])
            ];

            userSettings = {
              # "breadcrumbs.enabled" = true;

              "editor.fontFamily" = lib.mkForce config.font.monospaceNerdFont;
              "editor.fontSize" = lib.mkForce 14;
              "editor.fontLigatures" = true;
              "editor.formatOnSave" = true;
              "editor.tabSize" = 2;
              "editor.wordWrap" = "on";

              # "explorer.confirmDelete" = false;

              "files.insertFinalNewline" = true;

              "security.workspace.trust.banner" = "never";
              "security.workspace.trust.enabled" = false;
              "security.workspace.trust.startupPrompt" = "never";
              "security.workspace.trust.untrustedFiles" = "open";

              "terminal.integrated.fontFamily" = config.font.monospaceNerdFont;

              "update.mode" = "none";
            };
          };
        };
      }
    ];

    environment = lib.mkIf (config.vscode.package == pkgs.vscodium) {
      shellAliases = {
        code = "codium";
      };

      systemPackages = [ config.vscode.package ];

      variables = {
        VSCODE_GALLERY_SERVICE_URL = "https://marketplace.visualstudio.com/_apis/public/gallery";
        VSCODE_GALLERY_ITEM_URL = "https://marketplace.visualstudio.com/items";
        VSCODE_GALLERY_CACHE_URL = "https://vscode.blob.core.windows.net/gallery/index";
        VSCODE_GALLERY_CONTROL_URL = "";
      };
    };
  };
}
