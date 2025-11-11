{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  mk =
    type: default:
    lib.mkOption {
      type = type;
      default = default;
    };
  mkAttrsOf = type: mk (lib.types.attrsOf type);
  mkListOf = type: mk (lib.types.listOf type);

  reduceUsers =
    fn:
    builtins.listToAttrs (
      map (user: {
        name = user;
        value = fn user;
      }) config.user.usernames
    );
in
{
  options = with lib.types; {
    macos.home-manager = mkAttrsOf anything { };
    macos.homebrew.casks = mkListOf str [ ];
    macos.user = mkAttrsOf anything { };

    nixos.environment.systemPackages = mkListOf package [ ];
    nixos.fonts.fontconfig = mkAttrsOf anything { };
    nixos.hardware = mkAttrsOf anything { };
    nixos.programs = mkAttrsOf attrs { };
    nixos.services = mkAttrsOf attrs { };
    nixos.systemd.services = mkAttrsOf attrs { };
    nixos.user = mkAttrsOf anything { };
    nixos.users = mkAttrsOf anything { };

    hostname = mk str null;

    unfreePackages = mkListOf str [ ];

    user = {
      github.username = mk str "jhenderiks";
      homeBase = mk str "/home";
      shell = mk str "fish";
      usernames = mkListOf str null;
      users = mkAttrsOf anything { };
    };
  };

  config = lib.mkMerge [
    {
      # needs this so it knows where to put sharedModules, apparently
      home-manager.users = reduceUsers (user: { });

      networking.hostName = config.hostname;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      users.users = reduceUsers (
        user:
        lib.mkMerge [
          config.user.users
          {
            home = "${config.user.homeBase}/${user}";
            shell = pkgs.${config.user.shell};
          }
        ]
      );
    }
  ];
}
