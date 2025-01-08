{
  config,
  lib,
  pkgs,
  ...
}: let
  nordvpnPkg = pkgs.callPackage ({
    autoPatchelfHook,
    buildFHSEnvChroot,
    dpkg,
    fetchurl,
    lib,
    stdenv,
    sysctl,
    iptables,
    iproute2,
    procps,
    cacert,
    libxml2,
    libidn2,
    zlib,
    wireguard-tools,
  }: let
    pname = "nordvpn";
    version = "3.18.3";

    nordvpnBase = stdenv.mkDerivation {
      inherit pname version;

      src = fetchurl {
        url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
        hash = "sha256-pCveN8cEwEXdvWj2FAatzg89fTLV9eYehEZfKq5JdaY=";
      };

      buildInputs = [libxml2 libidn2];
      nativeBuildInputs = [dpkg autoPatchelfHook stdenv.cc.cc.lib];

      dontConfigure = true;
      dontBuild = true;

      unpackPhase = ''
        runHook preUnpack
        dpkg --extract $src .
        runHook postUnpack
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        mv usr/* $out/
        mv var/ $out/
        mv etc/ $out/
        runHook postInstall
      '';
    };

    nordvpnfhs = buildFHSEnvChroot {
      name = "nordvpnd";
      runScript = "nordvpnd";

      # hardcoded path to /sbin/ip
      targetPkgs = pkgs: [
        nordvpnBase
        sysctl
        iptables
        iproute2
        procps
        cacert
        libxml2
        libidn2
        zlib
        wireguard-tools
      ];
    };
  in
    stdenv.mkDerivation {
      inherit pname version;

      dontUnpack = true;
      dontConfigure = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin $out/share
        ln -s ${nordvpnBase}/bin/nordvpn $out/bin
        ln -s ${nordvpnfhs}/bin/nordvpnd $out/bin
        ln -s ${nordvpnBase}/share/* $out/share/
        ln -s ${nordvpnBase}/var $out/
        runHook postInstall
      '';

      meta = with lib; {
        description = "CLI client for NordVPN";
        homepage = "https://www.nordvpn.com";
        license = licenses.unfreeRedistributable;
        maintainers = with maintainers; [dr460nf1r3];
        platforms = ["x86_64-linux"];
      };
    }) {};
in
  with lib; {
    options.nordvpn.enable = mkOption {
      type = types.bool;
      default = false;
    };

    config = mkIf config.nordvpn.enable {
      networking.firewall.checkReversePath = false;

      environment.systemPackages = [nordvpnPkg];

      nixos.users.groups.nordvpn = {};
      nixos.users.groups.nordvpn.members = config.user.usernames;

      systemd = {
        services.nordvpn = {
          description = "NordVPN daemon.";
          serviceConfig = {
            ExecStart = "${nordvpnPkg}/bin/nordvpnd";
            ExecStartPre = pkgs.writeShellScript "nordvpn-start" ''
              mkdir -m 700 -p /var/lib/nordvpn;
              if [ -z "$(ls -A /var/lib/nordvpn)" ]; then
                cp -r ${nordvpnPkg}/var/lib/nordvpn/* /var/lib/nordvpn;
              fi
            '';
            NonBlocking = true;
            KillMode = "process";
            Restart = "on-failure";
            RestartSec = 5;
            RuntimeDirectory = "nordvpn";
            RuntimeDirectoryMode = "0750";
            Group = "nordvpn";
          };
          wantedBy = ["multi-user.target"];
          after = ["network-online.target"];
          wants = ["network-online.target"];
        };
      };

      unfreePackages = ["nordvpn"];
    };
  }
