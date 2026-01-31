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
in
{
  options = with lib.types; {
    macos.home-manager = mkAttrsOf anything { };
    macos.homebrew.casks = mkListOf str [ ];
    macos.launchd = mkAttrsOf attrs { };
    macos.user = mkAttrsOf anything { };

    nixos.environment.systemPackages = mkListOf package [ ];
    nixos.fonts.fontconfig = mkAttrsOf anything { };
    nixos.hardware = mkAttrsOf anything { };
    nixos.programs = mkAttrsOf attrs { };
    nixos.services = mkAttrsOf attrs { };
    nixos.systemd.services = mkAttrsOf attrs { };
    nixos.systemd.user = mkAttrsOf attrs { };
    nixos.user = mkAttrsOf anything { };
    nixos.users = mkAttrsOf anything { };

    hostname = mk str null;

    unfreePackages = mkListOf str [ ];

    user = {
      github.username = mk str "jhenderiks";
      homeBase = mk str "/home";
      name = mk str "justin";
      shell = mk str "fish";
      users = mkAttrsOf anything { };
    };
  };

  config = lib.mkMerge [
    {
      home-manager.users.${config.user.name} = { };

      networking.hostName = config.hostname;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      users.users.${config.user.name} = lib.mkMerge [
        config.user.users
        {
          home = "${config.user.homeBase}/${config.user.name}";
          shell = pkgs.${config.user.shell};
        }
      ];
    }
  ];
}
