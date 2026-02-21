{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  imports = [
  ];

  nixpkgs = {
    
    # You can add overlays here
    #overlays = [
    #  outputs.overlays.additions
    #  outputs.overlays.modifications
    #  outputs.overlays.stable-packages
    #];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    clock24 = true;
    sensibleOnTop = false;
    shell = "\\${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    customPaneNavigationAndResize = true;
    mouse = true;
    newSession = true;
    keyMode = "vi";
    plugins = with pkgs; [
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.tmux-fzf
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'moon'
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contens 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
        '';
      }
    ];
    extraConfig = ''
      unbind %
      bind | split-window -h
      unbind '"'
      bind - split-window -v

      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      bind -r m resize-pane -Z

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane
    '';
  };

  xdg.enable = true;
  
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1300;
      scan_timeout = 50;
      format = "$all$nix_shell$nodejs$lua$golang$rust$php$git_branch$git_commit$git_state$git_status\n$username$hostname$directory";
      character = {
        success_symbol = "[](bold green) ";
        error_symbol = "[✗](bold red) ";
      };
    };
  };

  home.packages = with pkgs; [
    alejandra

    fastfetch
    bottom

    ripgrep
    fd

    sl
    zsh-fzf-tab
    copyq

    pass
    gnupg

    libqalculate

    yazi
  ];

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;

  #services.gpg-agent = {
  #  enable = true;
  #  enableZshIntegration = true;
  #  pinentryPackage = pkgs.pinentry-qt;
  #};

  programs.git = {
    enable = true;
    userName = "Sridhar Kedlaya";
    userEmail = "kedlayasridhar@gmail.com";
  };

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    shellAliases = {
      ll = "eza -l";
      update = "sudo nixos-rebuild switch --flake ~/flake_firestorm/";
      home-update = "home-manager switch";
      cd = "z";
      ls = "eza";
      rm = "trash -c always put";
      cat = "bat";
      vim = "nvim";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["sudo" "colored-man-pages" "direnv" "git" "git-commit"];
    };

    history = {
      share = true;
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux = {
      enableShellIntegration = true;
    };
  };

  home.username = "lightweaver";
  home.homeDirectory = "/home/lightweaver";

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}

