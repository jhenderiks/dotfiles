
{
  inputs = {
    catppuccin.url = "github:catppuccin/nix";

    catppuccin-vsc.url = "github:catppuccin/vscode";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    mac-app-util.url = "github:hraban/mac-app-util";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
  };

  outputs = inputs: let
    args = {
      inherit inputs;
    };
  in {
    darwinConfigurations = {
      work = import ./hosts/work args;
    };
    
    nixosConfigurations = {
      spinel = import ./hosts/spinel args;
    };
  };
}
