{ config, lib, options, pkgs, ... }:

let
  mk = type: default: lib.mkOption {
    type = type;
    default = default;
  };
  mkAttrsOf = type: mk (lib.types.attrsOf type);
  mkListOf = type: mk (lib.types.listOf type);

  reduceUsers = fn: builtins.listToAttrs (
    map (
      user: { name = user; value = fn user; }
    ) config.user.names
  );
in {
  options = with lib.types; {
    macos.homebrew.casks = mkListOf str [];

    nixos.environment.systemPackages = mkListOf package [];
    nixos.services = mkAttrsOf attrs {};
    nixos.systemd.services = mkAttrsOf attrs {};

    hostname = mk str null;

    unfreePackages = mkListOf str [];

    user = {
      hashedPassword = mk str null;
      home-manager = mkAttrsOf anything {};
      homeBase = mk str "/home";
      names = mkListOf str null;
      shell = mk str "fish";
      user = mkAttrsOf anything {};
    };
  };

  config = lib.mkMerge [
    {
      home-manager.users = reduceUsers (user: config.user.home-manager);

      networking.hostName = config.hostname;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      users.users = reduceUsers (
        user: lib.mkMerge [
          config.user.user
          {
            home = "${config.user.homeBase}/${user}";
            shell = pkgs.${config.user.shell};
          }
        ]
      );
    }
  ];
}