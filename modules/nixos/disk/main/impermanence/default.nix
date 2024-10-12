{ config, lib, ... }:

let
  cfg = config.disk.main.impermanence;
in {
  imports = [
    ./root.nix
  ];

  config = lib.mkIf cfg.enable {
    environment.persistence.${cfg.dir} = {
      hideMounts = true;
    };

    fileSystems.${cfg.dir} = {
      neededForBoot = true;
    };
  };
}