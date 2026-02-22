{
  inputs,
  lib,
  config,
  pkgs,
  modulesPath,
  ...
} @ args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
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
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.rebuild
    inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.home-rebuild
  ];

  users.users.root.openssh.authorizedKeys.keys =
    [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEx2KGuEn8y49EnYj4IS2JrCwH3Me2DCnzyClAep+Gv5 sridhardked@gmail.com"
    ]
    ++ (args.extraPublicKeys or []); # this is used for unit-testing this module and can be removed if not needed

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

  services.nginx = {
    enable = true;
    virtualHosts."sridharkedlaya.xyz" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/root";

      locations."/.well-known/matrix/server" = {
        extraConfig = ''
      default_type application/json;
      return 200 '{ "m.server": "matrix.sridharkedlaya.xyz:443" }';
    '';
      };

      locations."/.well-known/matrix/client" = {
        extraConfig = ''
      default_type application/json;
      return 200 '{ "m.homeserver": { "base_url": "https://matrix.sridharkedlaya.xyz" } }';
      add_header Access-Control-Allow-Origin *;
    '';
      };
    };

    virtualHosts."matrix.sridharkedlaya.xyz" = {
      enableACME = true;
      forceSSL = true;
      recommendedProxySettings = true;

      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "kedlayasridhar@gmail.com";
  };

  sops.defaultSops.file = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/lightweaver/.config/sops/age/keys.txt";

  sops.secrets = {
    matrix_key = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
    matrix_registration_secret = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };

  services.dendrite = {
    enable = true;
    environmentFile = config.sops.secrets.matrix_registration_secret.path;
    settings = {
      global = {
        server_name = "sridharkedlaya.xyz";
        private_key = config.sops.secrets.matrix_key.path;
      };
      client_api.registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
    };
  };

  systemd.services.dendrite = {
    serviceConfig.SupplementaryGroups = [ config.users.groups.keys.name ];
  };

  users.users = {
    lightweaver = {
      isNormalUser = true;
      description = "Sridhar D Kedlaya";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "input" "uinput" "power" "docker" "keys"];
      packages = with pkgs; [];
      shell = pkgs.zsh;
    };
  };

  users.groups.keys = {};

  system.stateVersion = "24.05";
}
