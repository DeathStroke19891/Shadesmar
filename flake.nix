{
  description = "Flake Shadesmar";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs : let
  inherit (self) outputs;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  in 
  {
    formatter = nixpkgs.legacyPackages."x86_64-linux".alejandra;

    packages.${system}.rebuild = pkgs.callPackage ./pkgs/rebuild { };

    nixosConfigurations = {
      Shadesmar = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/configuration.nix
        ];
      };
    };
    
    homeConfigurations = {
      "lightweaver@Shadesmar" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/home.nix
        ];
      };
    };
  };
}
