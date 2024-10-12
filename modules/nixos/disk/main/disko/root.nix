{
  ESP = import ./boot.nix;
  root = {
    size = "100%";
    content = import ./content.nix;
  };
}