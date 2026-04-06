{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./agent-deck.nix
    ./cursor.nix
    ./docker.nix
    ./ghostty.nix
    ./kitty.nix
    ./opencode
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
    discord.enable = true;
    docker.enable = true;
    ghostty.enable = true;
    kitty.enable = true;
    mattermost.enable = true;
    agent-deck.enable = true;
    opencode.enable = true;
    # vscode.enable = true;

    environment.systemPackages = with pkgs; [
      jq
      nixfmt
      nixos-anywhere
      zed-editor-fhs
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
