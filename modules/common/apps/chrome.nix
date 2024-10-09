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
      enable = lib.mkEnableOption {
        default = false;
      };
    };
  };

  config = lib.mkIf config.chrome.enable (lib.mkMerge [
    # (lib.mkIf pkgs.stdenv.isDarwin {
    #   system.activationScripts.preUserActivation.text = lib.concatStrings [
    #     ''
    #       if [ ! -d ${macExtDir} ]; then
    #         sudo mkdir -p ${macExtDir}
    #       fi
    #     ''
    #     (lib.concatMapStrings (
    #       ext: ''
    #         if [ ! -f ${macExtFile ext} ]; then
    #           sudo sh -c 'echo "${macExtFileJson}" > ${macExtFile ext}'
    #         fi
    #       ''
    #     ) config.chromium.extensions)
    #   ];
    # })
    {
      chromium.enable = true;
      chromium.package = pkgs.google-chrome;

      cfg.unfreePackages = [ "google-chrome" ];
    }
  ]);
}