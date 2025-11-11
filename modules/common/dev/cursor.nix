{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = with lib; {
    cursor = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = lib.mkIf config.cursor.enable {
    unfreePackages = [ "cursor" ];
    vscode.enable = true;
    vscode.package = pkgs.code-cursor;
  };
}
