{ inputs, ... }:

{
  nixpkgs.overlays = [
    (_: prev: {
      # https://github.com/LnL7/nix-darwin/issues/1041
      inherit (inputs.nixpkgs-stable.legacyPackages.${prev.system}) karabiner-elements;
    })
  ];

  # services.karabiner-elements.enable = true;
}
