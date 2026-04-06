{
  config,
  lib,
  pkgs,
  ...
}:

let
  agent-deck = pkgs.stdenv.mkDerivation rec {
    pname = "agent-deck";
    version = "0.28.3";

    src = pkgs.fetchurl {
      url = "https://github.com/asheshgoplani/agent-deck/releases/download/v${version}/agent-deck_${version}_linux_amd64.tar.gz";
      sha256 = "sha256-1l6DarUTGWA380Zq0p5E5zrHX+pd1Y6GR4pBDJnHjx0=";
    };

    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.glibc ];

    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp agent-deck $out/bin/agent-deck
      chmod +x $out/bin/agent-deck
    '';
  };
in
{
  options = {
    agent-deck = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.agent-deck.enable {
    environment.systemPackages = [
      agent-deck
      pkgs.tmux
      pkgs.jq
    ];
  };
}
