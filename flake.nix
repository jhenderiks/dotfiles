
{
  inputs = {
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let
    args = {
      inherit inputs;
      fn = {
        # mkUserAttrSet = (attrSet: builtins.listToAttrs (
        #   map (user: { name = user; value = { test = "foo"; }; }) users
        # ));
      };
    };
  in {
    nixosConfigurations = {};

    darwinConfigurations = {
      work = import ./hosts/work args;
    };
  };
}
