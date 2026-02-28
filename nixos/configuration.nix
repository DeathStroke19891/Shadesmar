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
    vim
    sops
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

      locations."/_matrix" = {
        proxyPass = "http://127.0.0.1:8008";
        proxyWebsockets = true;
      };
    };
    virtualHosts."misskey.sridharkedlaya.xyz" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true; # needed if you need to use WebSocket
        # extraConfig =
        #   # required when the target is also TLS server with multiple hosts
        #   "proxy_ssl_server_name on;" +
        #   # required when the server wants to use HTTP Authentication
        #   "proxy_pass_header Authorization;"
        #   ;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    acceptTerms = true;
    defaults.email = "kedlayasridhar@gmail.com";
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/lightweaver/.config/sops/age/keys.txt";

  sops.secrets = {
    matrix_key = {
      owner = "dendrite";
    };
    matrix_registration_secret = {
      owner = "dendrite";
    };
  };

  services.dendrite = {
    enable = true;
    settings = {
      global = {
        server_name = "sridharkedlaya.xyz";
        private_key = config.sops.secrets.matrix_key.path;
      };
    };
  };

  systemd.services.dendrite = {
    serviceConfig = {
      User = "dendrite";
      EnvironmentFile = config.sops.secrets.matrix_registration_secret.path;
    };
  };

  users.groups.dendrite = {};

  users.users.dendrite = {
    isSystemUser = true;
    createHome = false;
    group = "dendrite";
  };

  users.users = {
    lightweaver = {
      isNormalUser = true;
      description = "Sridhar D Kedlaya";
      extraGroups = ["networkmanager" "wheel" "video" "audio" "input" "uinput" "power" "docker"];
      packages = with pkgs; [];
      shell = pkgs.zsh;
    };
  };

  system.stateVersion = "24.05";
}
