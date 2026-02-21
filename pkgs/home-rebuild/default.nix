{pkgs}:
pkgs.writeShellScriptBin "home-rebuild" ''
  set -e
  pushd ~/shadesmar/home-manager/
  ${pkgs.alejandra}/bin/alejandra . &>/dev/null
  ${pkgs.git}/bin/git diff -U0 *.nix
  popd
  pushd ~/shadesmar
  echo "home-manager Rebuilding..."
  ${pkgs.home-manager}/bin/home-manager switch --flake .#lightweaver@Shadesmar &>~/shadesmar/home-switch.log || ( cat home-switch.log | grep --color error && false)
  gen=$(home-manager generations | head -n 1)
  ${pkgs.git}/bin/git commit -am "$gen"
''
