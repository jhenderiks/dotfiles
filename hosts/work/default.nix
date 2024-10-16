
{ inputs, ... }:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    ../../modules/common
    ../../modules/macos
    ./.config.nix
    {
      bitwarden.enable = true;
      brave.enable = true;
      chrome.enable = true;
      firefox.enable = true;
      keepassxc.enable = true;
      kitty.enable = true;
      ledger-live.enable = true;
      slack.enable = true;
      spotify.enable = true;
      vscode.enable = true;
      zoom.enable = true;
    }
  ];
}
