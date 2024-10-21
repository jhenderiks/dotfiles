{ config, inputs, lib, pkgs, ... }:

# TODO: if catppuccin.enable

let
  open-vsx = inputs.nix-vscode-extensions.extensions.${pkgs.system}.open-vsx;
  vscode-marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in {
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

    user.home-manager = {
      programs.vscode = {
        enable = true;

        package = config.vscode.package;

        enableUpdateCheck = true;
        enableExtensionUpdateCheck = true;
        mutableExtensionsDir = false;

        extensions = builtins.concatLists [
          # [(pkgs.catppuccin-vsc.override {
          #   colorOverrides = {
          #     mocha = {
          #       # # 1 step down
          #       # base = "#1c1c2b";
          #       # mantle = "#161622";
          #       # crust = "#101019";

          #       # # 2 steps down
          #       # base = "#1a1a28";
          #       # mantle = "#14141f";
          #       # crust = "#0e0e16";
          #     };
          #   };
          # })]
          (with open-vsx; [
            catppuccin.catppuccin-vsc
            catppuccin.catppuccin-vsc-icons
            golang.go
            jnoortheen.nix-ide
            ms-azuretools.vscode-docker
            ms-kubernetes-tools.vscode-kubernetes-tools
          ])
          (with vscode-marketplace; [
            ms-vscode-remote.remote-ssh
          ])
        ];

        userSettings = {
          # "breadcrumbs.enabled" = true;
          "editor.fontFamily" = "'${config.font.monospaceNerdFont}'";
          "editor.fontLigatures" = true;
          "editor.fontSize" = 16;
          "editor.tabSize" = 2;
          "editor.wordWrap" = "on";
          "files.insertFinalNewline" = true;
          # "explorer.confirmDelete" = false;
          "security.workspace.trust.banner" = "never";
          "security.workspace.trust.enabled" = false;
          "security.workspace.trust.startupPrompt" = "never";
          "security.workspace.trust.untrustedFiles" = "open";
          "telemetry.telemetryLevel" = "off";
          "workbench.colorTheme" = "Catppuccin Mocha";
          "workbench.iconTheme" = "catppuccin-mocha";

          # recommended catppuccin settings
          "editor.semanticHighlighting.enabled" = true;
          "terminal.integrated.minimumContrastRatio" = 1;
          "window.titleBarStyle" = "custom";
          "gopls" = {
            "ui.semanticTokens" = true;
          };
        };
      };
    };


    environment.shellAliases.code = lib.mkIf (config.vscode.package == pkgs.vscodium) "codium";

    environment.systemPackages = [ config.vscode.package ];

    environment.variables = {
      VSCODE_GALLERY_SERVICE_URL = "https://marketplace.visualstudio.com/_apis/public/gallery";
      VSCODE_GALLERY_ITEM_URL = "https://marketplace.visualstudio.com/items";
      VSCODE_GALLERY_CACHE_URL = "https://vscode.blob.core.windows.net/gallery/index";
      VSCODE_GALLERY_CONTROL_URL = "";
    };

    nixpkgs.overlays = [inputs.catppuccin-vsc.overlays.default];
  };
}
