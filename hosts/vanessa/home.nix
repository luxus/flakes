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
