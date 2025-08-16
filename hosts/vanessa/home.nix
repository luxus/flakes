# Home Manager configuration for vanessa
# This file is isolated and can be easily removed or replaced
{ config, pkgs, lib, osConfig, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "luxus";
  home.homeDirectory = "/home/luxus";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Basic packages for user environment
  home.packages = with pkgs; [
    
    
    # System utilities
    file
    which
    
    # Network tools
    nmap
    tcpdump
  ];

  # Basic git configuration
  programs.git = {
    enable = true;
    userName = "luxus";
    userEmail = "luxuspur@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # Zsh shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      update = "sudo nixos-rebuild switch --flake .";
    };

    initContent = ''
      # Custom zsh configuration
      export EDITOR=nvim
      export PAGER=less

      # Enable colors
      autoload -U colors && colors

      # Simple prompt
      PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '
    '';
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Ghostty terminal configuration (isolated and easily replaceable)
  programs.ghostty = {
    enable = true;
    package = lib.mkIf pkgs.stdenv.isDarwin null;
    installBatSyntax = lib.mkIf pkgs.stdenv.isDarwin false;

    settings = {
      keybind = [
        "super+c=copy_to_clipboard"
        "global:alt+enter=toggle_quick_terminal"
        "super+shift+h=goto_split:left"
        "super+shift+j=goto_split:bottom"
        "super+shift+k=goto_split:top"
        "super+shift+l=goto_split:right"
      ];

      font-family = "TX-02";
      font-size = 15;
      background-opacity = 0.85;
      alpha-blending = "linear";

      macos-window-shadow = false;
      copy-on-select = false;
      cursor-style-blink = true;
      unfocused-split-opacity = 0.6;
      macos-non-native-fullscreen = false;
      macos-option-as-alt = "left";
      custom-shader = "shaders/cursor_smear_fade.glsl";
      theme = "dark:kanso-zen,light:kanso-pearl";
      clipboard-paste-protection = false;
      quit-after-last-window-closed-delay = "2h";
    };

    themes = {
      "kanagawa-paper-canvas" = {
        palette = [
          "0=#393836" # sumiInk5
          "1=#c4746e" # autumnRed
          "2=#699469" # autumnGreen
          "3=#c4b28a" # boatYellow2
          "4=#435965" # dragonBlue
          "5=#a292a3" # dragonPink
          "6=#8ea49e" # waveAqua1
          "7=#c8c093" # oldWhite
          "8=#aca9a4" # dragonWhite
          "9=#cc928e" # surimiOrange
          "10=#72a072" # dragonGreen
          "11=#d4c196" # carpYellow
          "12=#698a9b" # crystalBlue
          "13=#b4a7b5" # oniViolet
          "14=#96ada7" # waveAqua2
          "15=#d5cd9d" # fujiWhite
        ];
        background = "#dcd7ba";
        foreground = "#1f1f28";
        "cursor-color" = "#c4b28a";
        "selection-background" = "#c4b9a2";
        "selection-foreground" = "#393836";
      };
      "kanso-ink" = {
        palette = [
          "0=#14171d" # sumiInk0
          "1=#c4746e" # autumnRed
          "2=#8a9a7b" # autumnGreen
          "3=#c4b28a" # boatYellow2
          "4=#8ba4b0" # dragonBlue
          "5=#a292a3" # dragonPink
          "6=#8ea4a2" # waveAqua1
          "7=#c8c093" # oldWhite
          "8=#a4a7a4" # dragonWhite
          "9=#e46876" # surimiOrange
          "10=#87a987" # dragonGreen
          "11=#e6c384" # carpYellow
          "12=#7fb4ca" # crystalBlue
          "13=#938aa9" # oniViolet
          "14=#7aa89f" # waveAqua2
          "15=#c5c9c7" # fujiWhite
        ];
        background = "#14171d";
        foreground = "#c5c9c7";
        "cursor-color" = "#c5c9c7";
        "selection-background" = "#393B42";
        "selection-foreground" = "#c5c9c7";
      };
      "kanso-pearl" = {
        palette = [
          "0=#24262D" # sumiInk0
          "1=#c84053" # autumnRed
          "2=#6f894e" # autumnGreen
          "3=#77713f" # boatYellow2
          "4=#4d699b" # dragonBlue
          "5=#b35b79" # dragonPink
          "6=#597b75" # waveAqua1
          "7=#545464" # oldWhite
          "8=#6d6f6e" # dragonWhite
          "9=#d7474b" # surimiOrange
          "10=#6e915f" # dragonGreen
          "11=#836f4a" # carpYellow
          "12=#6693bf" # crystalBlue
          "13=#624c83" # oniViolet
          "14=#5e857a" # waveAqua2
          "15=#43436c" # fujiWhite
        ];
        background = "#f2f1ef";
        foreground = "#24262D";
        "cursor-color" = "#24262D";
        "selection-background" = "#e2e1df";
        "selection-foreground" = "#24262D";
      };
      "kanso-zen" = {
        palette = [
          "0=#090E13" # sumiInk0
          "1=#c4746e" # autumnRed
          "2=#8a9a7b" # autumnGreen
          "3=#c4b28a" # boatYellow2
          "4=#8ba4b0" # dragonBlue
          "5=#a292a3" # dragonPink
          "6=#8ea4a2" # waveAqua1
          "7=#c8c093" # oldWhite
          "8=#a4a7a4" # dragonWhite
          "9=#e46876" # surimiOrange
          "10=#87a987" # dragonGreen
          "11=#e6c384" # carpYellow
          "12=#7fb4ca" # crystalBlue
          "13=#938aa9" # oniViolet
          "14=#7aa89f" # waveAqua2
          "15=#c5c9c7" # fujiWhite
        ];
        background = "#090E13";
        foreground = "#c5c9c7";
        "cursor-color" = "#c5c9c7";
        "selection-background" = "#24262D";
        "selection-foreground" = "#c5c9c7";
      };
      "kanagawa-paper-ink" = {
        palette = [
          "0=#393836" # sumiInk5
          "1=#c4746e" # autumnRed
          "2=#699469" # autumnGreen
          "3=#c4b28a" # boatYellow2
          "4=#435965" # dragonBlue
          "5=#a292a3" # dragonPink
          "6=#8ea49e" # waveAqua1
          "7=#c8c093" # oldWhite
          "8=#aca9a4" # dragonWhite
          "9=#cc928e" # surimiOrange
          "10=#72a072" # dragonGreen
          "11=#d4c196" # carpYellow
          "12=#698a9b" # crystalBlue
          "13=#b4a7b5" # oniViolet
          "14=#96ada7" # waveAqua2
          "15=#d5cd9d" # fujiWhite
        ];
        background = "#1f1f28";
        foreground = "#dcd7ba";
        "cursor-color" = "#c4b28a";
        "selection-background" = "#766b90";
        "selection-foreground" = "#9e9b93";
      };
    };
  };

  # Stylix theming configuration (isolated and easily replaceable)
  stylix = {
    enable = true;

    # Use a base16 color scheme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    polarity = "dark"; # or "light"

    # Configure fonts for consistency
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
  };

  # XDG directories
  xdg.enable = true;

  # KDE Plasma configuration (isolated and easily replaceable)
  programs.plasma = {
    enable = true;

    # Basic workspace configuration
    workspace = {
      # Set a nice wallpaper (optional)
      # wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Next/contents/images/1920x1080.png";

      # Color scheme
      colorScheme = "BreezeDark";

      # Cursor theme
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };

      # Icon theme
      iconTheme = "breeze-dark";
    };

    # Basic shortcuts
    shortcuts = {
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "org.kde.konsole.desktop"."_launch" = "Meta+Return";
      "org.kde.krunner.desktop"."_launch" = ["Alt+Space" "Alt+F2"];
    };

    # Configure some basic KDE applications
    configFile = {
      # Konsole configuration
      "konsolerc"."Desktop Entry"."DefaultProfile" = "luxus.profile";

      # Dolphin configuration
      "dolphinrc"."General"."BrowseThroughArchives" = true;
      "dolphinrc"."General"."ShowFullPath" = true;
    };
  };
  
  # Basic file associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "application/pdf" = "firefox.desktop";
    };
  };
}
