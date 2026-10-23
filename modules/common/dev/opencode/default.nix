{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.opencode = {
    enable = lib.mkEnableOption "opencode AI coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
      description = "The opencode package to install.";
    };
  };

  config = lib.mkIf config.opencode.enable {
    environment.systemPackages = [ config.opencode.package ];
  };
}
