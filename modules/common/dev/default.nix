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
    discord.enable = true;
    docker.enable = true;
    ghostty.enable = true;
    kitty.enable = true;
    mattermost.enable = true;
    opencode.enable = true;
    vscode.enable = true;

    environment.systemPackages = with pkgs; [
      jq
      nixfmt
      nixos-anywhere
      ungoogled-chromium
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
