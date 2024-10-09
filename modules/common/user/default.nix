{ config, inputs, lib, pkgs, ... }:

let
  _map = fn: builtins.listToAttrs (
    map (user: { name = user; value = fn user; }) (import ../../../config/users.nix)
  );
in {
  config = {
    users.users = _map (user: {
      home = "${config.cfg.homeBase}/${user}";
      shell = pkgs.${config.cfg.shell};
    });

    home-manager.users = _map (user: lib.mkMerge [
      config.cfg.homeManagerShared
      { home.stateVersion = "24.11"; }
    ]);
  };
}