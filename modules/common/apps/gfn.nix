{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.gfn = {
    enable = lib.mkEnableOption "the official NVIDIA GeForce NOW client";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./gfn-package.nix { };
      description = "The GeForce NOW package to install.";
    };
  };

  config = lib.mkIf config.gfn.enable {
    nixos.environment.systemPackages = [ config.gfn.package ];
    unfreePackages = [ "gfn" ];
  };
}
