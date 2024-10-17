{ config, lib, pkgs, ... }:

let
  macExtDir = "/Library/Application\\ Support/Google/Chrome/External\\ Extensions";
  macExtFile = ext: "${macExtDir}/${ext}.json";
  macExtFileJson = ''
    {
      \"update_url\": \"https://clients2.google.com/service/update2/crx\"
    }
  '';
in {
  options = {
    chrome = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.chrome.enable {
    unfreePackages = [ "google-chrome" ];

    environment.systemPackages = [ pkgs.google-chrome ];

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