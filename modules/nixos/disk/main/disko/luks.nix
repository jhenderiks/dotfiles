{
  ESP = import ./boot.nix;
  luks = {
    size = "100%";
    content = {
      type = "luks";
      name = "crypt";
      settings.allowDiscards = true;
      content = import ./content.nix;
    };
  };
}
