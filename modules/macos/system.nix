{ lib, pkgs, ... }:

{
  config = {
    system = {
      stateVersion = 5;

      defaults = {
        CustomUserPreferences = {
          "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.finder" = {
            FXDefaultSearchScope = "SCcf";
            FXPreferredViewStyle = "clmv";
          };
        };

        dock = {
          autohide = true;
          enable-spring-load-actions-on-all-items = true;
          show-recents = false;
          showhidden = true;

          persistent-apps = [
            "/Applications/Nix Apps/Google Chrome.app"
            "/Applications/Nix Apps/Kitty.app"
          ];
        };

        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          
          CreateDesktop = false;

          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv";

          QuitMenuItem = true;

          ShowPathbar = true;
          ShowStatusBar = true;
        };

        LaunchServices.LSQuarantine = false;

        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleKeyboardUIMode = 3;

          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          NSNavPanelExpandedStateForSaveMode = true;

          PMPrintingExpandedStateForPrint = true;

          "com.apple.swipescrolldirection" = false;
        };

        screencapture.location = "~/Downloads";

        # https://github.com/LnL7/nix-darwin/issues/826
        # "com.apple.speech.recognition.AppleSpeechRecognition.prefs" = {
        #   CustomizedDictationHotKey = {
        #     keyChar = 65535;
        #     modifiers = 0;
        #     virtualKey = 96;
        #   };
        # };

        trackpad.Clicking = true;
      };
    };

    launchd.user.agents.UserKeyMapping.serviceConfig = {
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--match"
        "{\"ProductID\":0xc8,\"VendorID\":0x258a,\"Product\":\"RK Bluetooth Keyboard\"}"
        "--set"
        (
          let
            # https://hidutil-generator.netlify.app
            leftCommand = "0x7000000E3";
            leftOption = "0x7000000E2";
            rightCommand = "0x7000000E7";
            rightOption = "0x7000000E6";
          in
          ''
            {
              "UserKeyMapping": [
                {
                  "HIDKeyboardModifierMappingDst": ${leftCommand},
                  "HIDKeyboardModifierMappingSrc": ${leftOption}
                },
                {
                  "HIDKeyboardModifierMappingDst": ${leftOption},
                  "HIDKeyboardModifierMappingSrc": ${leftCommand}
                },
                {
                  "HIDKeyboardModifierMappingDst": ${rightCommand},
                  "HIDKeyboardModifierMappingSrc": ${rightOption}
                },
                {
                  "HIDKeyboardModifierMappingDst": ${rightOption},
                  "HIDKeyboardModifierMappingSrc": ${rightCommand}
                }
              ]
            }
          ''
        )
      ];
      LaunchEvents = {
        "com.apple.iokit.matching" = {
          "com.apple.device-attach" = {
            idProduct = "*";
            idVendor = "*";
            IOMatchLaunchStream = true;
            IOMatchStream = true;
            IOProviderClass = "IOUSBDevice";
          };
        };
      };
      RunAtLoad = true;
    };
  };
}
