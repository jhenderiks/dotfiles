
{ inputs, ... }:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    ../../modules/common
    ../../modules/macos
    ./.config.nix
    ({ lib, ... }: {
      user.github.username = lib.mkDefault null;

      bitwarden.enable = true;
      chrome.enable = true;
      kitty.enable = true;
      slack.enable = true;
      spotify.enable = true;
      vscode.enable = true;
      zoom.enable = true;
    })
  ];
}
