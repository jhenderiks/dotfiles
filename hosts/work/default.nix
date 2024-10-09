
{ inputs, ... }:

inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.mac-app-util.darwinModules.default
    ../../modules/common
    ../../modules/macos
    {
      bitwarden.enable = true;
      chrome.enable = true;
      kitty.enable = true;
      slack.enable = true;
      spotify.enable = true;
      vscode.enable = true;
    }
  ];
}
