{
  description = "Flake Shadesmar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs : let
  inherit (self) outputs;
  in 
  {
    formatter = nixpkgs.legacyPackages."x86_64-linux".alejandra;

    nixosConfigurations = {
      Shadesmar = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
