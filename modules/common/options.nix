{ config, lib, pkgs, ... }:

let
  mk = type: default: lib.mkOption {
    type = type;
    default = default;
  };
  mkAttrsOf = type: mk (lib.types.attrsOf type);
  mkListOf = type: mk (lib.types.listOf type);
  mkNoDefault = type: lib.mkOption { type = type; };

  osCommonOptions = with lib.types; {
    _user = mk attrs {};
    environment.systemPackages = mkListOf package [];
    programs = mkAttrsOf attrs {};
    services = mkAttrsOf attrs {};
  };

  osModule = with lib; osSpecificOptions: mkOption {
    type = types.submoduleWith {
      modules = [
        { options = osCommonOptions; }
        { options = osSpecificOptions; }
      ];
    };
  };

  osConfig = builtins.mapAttrs (
    name: value: lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isDarwin config._macos.${name})
      (lib.mkIf pkgs.stdenv.isLinux config._nixos.${name})
    ]
  ) osCommonOptions;

  reduceUsers = fn: builtins.listToAttrs (
    map (
      user: { name = user; value = fn user; }
    ) config._user.users
  );
in {
  options = with lib.types; {
    _hostname = mk str null;

    _macos = osModule {
      homebrew.casks = mkListOf str [];
    };

    _nixos = osModule {
      systemd.services = mkAttrsOf attrs {};
    };

    _unfreePackages = mkListOf str [];

    _user = {
      config = {
        # TODO: make setter functions for these that supply user as a variable?
        home-manager = mkAttrsOf anything {};
        users = mkAttrsOf anything {};
      };

      hashedPassword = mk str null;
      homeBase = mk str "/home";
      shell = mk str "fish";
      users = mkListOf str null;
    };
  };

  config = lib.mkMerge [
    osConfig
    {
      home-manager.users = reduceUsers (user: config._user.config.home-manager);

      networking.hostName = config._hostname;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config._unfreePackages;

      users.users = reduceUsers (
        user: lib.mkMerge [
          config._user.config.users
          {
            home = "${config._user.homeBase}/${user}";
            shell = pkgs.${config._user.shell};
          }
        ]
      );
    }
  ];
}