{
  type = "btrfs";
  extraArgs = [ "-f" ];
  subvolumes = {
    "/root" = {
      mountpoint = "/";
      mountOptions = [ "compress=zstd" "noatime" ];
    };
    "/home" = {
      mountpoint = "/home";
      mountOptions = [ "compress=zstd" "noatime" ];
    };
    "/nix" = {
      mountpoint = "/nix";
      mountOptions = [ "compress=zstd" "noatime" ];
    };
    "/state" = {
      mountpoint = "/state";
      mountOptions = [ "compress=zstd" "noatime" ];
    };
    "/swap" = {
      mountpoint = "/.swapvol";
      swap.swapfile.size = "8G";
    };
  };
}