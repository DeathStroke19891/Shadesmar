# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  rebuild = pkgs.callPackage ./rebuild {inherit pkgs;};
  home-rebuild = pkgs.callPackage ./home-rebuild {inherit pkgs;};
}

