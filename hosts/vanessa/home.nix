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
      update = "sudo nixos-rebuild switch";
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

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set tabstop=2
      set shiftwidth=2
      set expandtab
      set smartindent
      set wrap
      set ignorecase
      set smartcase
      set incsearch
      set hlsearch

      " Enable mouse support
      set mouse=a

      " Better colors
      set termguicolors

      " Show matching brackets
      set showmatch

      " Enable clipboard integration
      set clipboard=unnamedplus
    '';
  };

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };

  # XDG directories
  xdg.enable = true;
  
  # Basic file associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "nvim.desktop";
      "application/pdf" = "firefox.desktop";
    };
  };
}
