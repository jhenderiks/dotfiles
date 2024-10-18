{ config, lib, pkgs, ... }:

let
  macExtDir = "/Library/Application\\ Support/Google/chromium/External\\ Extensions";
  macExtFile = ext: "${macExtDir}/${ext}.json";
  macExtFileJson = ''
    {
      \"update_url\": \"https://clients2.google.com/service/update2/crx\"
    }
  '';
in {
  options = with lib; {
    chromium = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.ungoogled-chromium;
      };

      extensions = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  };

  config = lib.mkIf config.chromium.enable {
    environment.systemPackages = [ config.chromium.package ];

    chromium.extensions = [
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
    ];

    user.home-manager.programs.chromium = {
      enable = true;
      package = config.chromium.package;
      extensions = config.chromium.extensions;
    };

    # system.activationScripts.preUserActivation.text = lib.concatStrings [
    #   ''
    #     if [ ! -d ${macExtDir} ]; then
    #       sudo mkdir -p ${macExtDir}
    #     fi
    #   ''
    #   (lib.concatMapStrings (
    #     ext: ''
    #       if [ ! -f ${macExtFile ext} ]; then
    #         sudo sh -c 'echo "${macExtFileJson}" > ${macExtFile ext}'
    #       fi
    #     ''
    #   ) config.chromium.extensions)
    # ];
  };
}
