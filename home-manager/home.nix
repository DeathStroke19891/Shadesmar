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

  home.packages = with pkgs; [
    alejandra

    taskwarrior3
    taskwarrior-tui

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

    typst
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
    delta = {
      enable = true;
      package = pkgs.delta;
      options = {
        navigate = true;
        dark = true;
      };
    };
    extraConfig = {
      core = {
        compression = 9;
        whitespace = "error";
        preloadindex = true;
      };
      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = false;
      };
      url."git@github.com:DeathStroke19891/" = {
        insteadOf = "ds:";
      };
      url."git@github.com:" = {
        insteadOf = "gh:";
      };
      # url."ssh://git@github.com/" = {
      #   insteadOf = "https://github.com/";
      # };
      init = {
        defaultBranch = "dev";
      };
      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };
      merge = {
        conflictstyle = "zdiff3";
      };
      interactive = {
        singlekey = true;
      };
      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };
      commit = {
        verbose = true;
      };
      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };
      pull = {
        default = true;
        rebase = true;
      };
      rebase = {
        autoStash = true;
        missingCommitsCheck = "warn";
      };
      log = {
        abbrevCommit = true;
        graphColors = "blue,yellow,cyan,magenta,green,red";
      };
      color."decorate" = {
        HEAD = "red";
        branch = "blue";
        tag = "yellow";
        remoteBranch = "magenta";
      };
      color."branch" = {
        current = "magenta";
        local = "default";
        remote = "yellow";
        upstream = "green";
        plain = "blue";
      };
      branch = {
        sort = "-committerdate";
      };
      tag = {
        sort = "-taggerdate";
      };
      pager = {
        branch = false;
        tag = false;
      };
    };
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

      gs = "git status --short";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      gds = "git diff --staged";
      ga = "git add";
      gap = "git add --patch";
      gc = "git commit";
      gp = "git push";
      gu = "git pull";
      gl = "git log --all --graph --pretty=format:'%C(magenta)%h %C(white) %an %ar%C(auto) %D%n%s%n'";
      gb = "git branch";
      gi = "git init";
      gcl = "git clone";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["sudo" "colored-man-pages" "direnv"];
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

