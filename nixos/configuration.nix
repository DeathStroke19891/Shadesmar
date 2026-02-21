{
  inputs,
    lib,
    config,
    pkgs,
    modulesPath,
    ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  boot.loader.grub = {
# no need to set devices, disko will add all devices that have a EF02 partition to the list already
# devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
  ];

  users.users.root.openssh.authorizedKeys.keys =
    [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx2KGuEn8y49EnYj4IS2JrCwH3Me2DCnzyClAep+Gv5 sridhardked@gmail.com"
    ] ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

    nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
      substituters = [
      	"https://cache.nixos.org/"
      ];
    };

    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.podman.enable = true;

  environment.pathsToLink = ["/share/zsh"];
  programs.zsh.enable = true;

  networking.hostName = "Shadesmar";

  users.users = {
    lightweaver = {
      isNormalUser = true;
      description = "Sridhar D Kedlaya";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "input" "uinput" "power" "docker" "libvirtd" "kvm" "adbusers"];
      packages = with pkgs; [];
      shell = pkgs.zsh;
    };
  };

  system.stateVersion = "24.05";
}
