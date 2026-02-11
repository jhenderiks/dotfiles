{ config, inputs, lib, pkgs, ... }:

# TODO: if catppuccin.enable

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
    nixpkgs.overlays = [ inputs.nix-vscode-extensions.overlays.default ];

    environment.shellAliases.code =
      lib.mkIf (config.vscode.package == pkgs.vscodium) "codium";

    environment.systemPackages = [ config.vscode.package pkgs.nixfmt ];

    environment.variables = {
      VSCODE_GALLERY_SERVICE_URL =
        "https://marketplace.visualstudio.com/_apis/public/gallery";
      VSCODE_GALLERY_ITEM_URL = "https://marketplace.visualstudio.com/items";
      VSCODE_GALLERY_CACHE_URL =
        "https://vscode.blob.core.windows.net/gallery/index";
      VSCODE_GALLERY_CONTROL_URL = "";
    };

    unfreePackages = [
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-ms-vscode-remote-remote-ssh"
    ];

    user.home-manager = {
      # https://github.com/nix-community/home-manager/issues/6545
      programs.vscode = {
        enable = true;

        package = config.vscode.package;
        mutableExtensionsDir = false;

        profiles.default = {
          enableUpdateCheck = true;
          enableExtensionUpdateCheck = true;

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
            (with pkgs.open-vsx; [
              catppuccin.catppuccin-vsc
              golang.go
              jnoortheen.nix-ide
              ms-azuretools.vscode-docker
              ms-kubernetes-tools.vscode-kubernetes-tools
              redhat.vscode-yaml
            ])
            (with pkgs.vscode-marketplace; [
              github.copilot
              ms-vscode-remote.remote-ssh
            ])
          ];

          userSettings = {
            # "breadcrumbs.enabled" = true;
            "editor.fontFamily" = "'${config.font.monospaceNerdFont}'";
            "editor.fontLigatures" = true;
            "editor.fontSize" = 16;
            "editor.formatOnSave" = true;
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
            "gopls" = { "ui.semanticTokens" = true; };
          };
        };
      };
    };
  };
}
