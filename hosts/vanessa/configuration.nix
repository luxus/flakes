# NixOS configuration for vanessa
{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    # Add hardware-configuration.nix when available
    # ./hardware-configuration.nix
  ];

  # Facter hardware detection configuration
  facter.reportPath = ./facter.json;

  # System settings
  networking.hostName = "vanessa";
  
  # Nix configuration with Determinate Nix enhancements
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "lazy-trees"
    ];
    # Determinate Nix optimizations
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    # Enable lazy trees for better performance
    lazy-trees = true;
    # Improved substitution settings
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Nix garbage collection (complementary to Determinate Nixd)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel and boot configuration for NVIDIA
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "nvidia"
    "nvidia_modeset"
    "nvidia_drm"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelModules = [
    "nvidia-uvm"
    "kvm-intel"
  ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "vt.global_cursor_default=0"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  # Plymouth boot splash
  boot.plymouth.enable = true;
  boot.plymouth.theme = "nixos-bgrt";
  boot.plymouth.themePackages = [
    pkgs.nixos-bgrt-plymouth
  ];
  
  # Enable networking
  networking.networkmanager.enable = true;
  
  # Set time zone
  time.timeZone = "UTC";
  
  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Enable the X11 windowing system (optional, adjust as needed)
  # services.xserver.enable = true;
  
  # Define user accounts
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/AjBtg8D4lMoBkp2L3dDb5EmkOGr1v/Ns1wwRoKds4"
    ];
  };

  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS User";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Add user packages here
    ];
  };

  users.users.luxus = {
    isNormalUser = true;
    description = "Luxus";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    initialPassword = "password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/AjBtg8D4lMoBkp2L3dDb5EmkOGr1v/Ns1wwRoKds4"
    ];
    packages = with pkgs; [
      # User-specific packages
      tree
      htop
      neofetch
    ];
  };
  
  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      update = "sudo nixos-rebuild switch";
    };
  };
  environment.shells = with pkgs; [ zsh ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    zsh
    # NVIDIA and graphics packages
    cudatoolkit
    podman-compose
    libva
    libvdpau
    vdpauinfo # NOTE: vdpauinfo
    libva-utils # NOTE: vainfo
    vulkan-tools # NOTE: vulkaninfo
    glxinfo # NOTE: glxinfo and eglinfo
    nvtopPackages.full # NOTE: check GPU usage
    # Determinate Nix tools (if available)
    # Note: determinate-nixd is typically installed via the Determinate installer
  ];
  
  # NVIDIA Hardware Configuration
  hardware.graphics = {
    enable32Bit = true;
    enable = true;
    extraPackages32 = with pkgs.driversi686Linux; [
      libvdpau-va-gl
    ];
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };
  hardware.nvidia-container-toolkit.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;
    open = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  # Additional hardware support
  hardware.i2c.enable = true;

  # Determinate Nixd configuration
  environment.etc."determinate/config.json".text = builtins.toJSON {
    garbageCollector = {
      strategy = "automatic";
    };
    authentication = {
      additionalNetrcSources = [ ];
    };
  };

  # Environment variables for NVIDIA hardware acceleration
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia"; # NOTE: hardware acceleration
    VDPAU_DRIVER = "va_gl"; # NOTE: hardware acceleration
    GBM_BACKEND = "nvidia-drm"; # NOTE: wayland buffer api
    WLR_RENDERER = "gles2"; # NOTE: wayland roots compositor renderer
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # NOTE: offload opengl workloads to nvidia

    NVD_BACKEND = "direct"; # NOTE: nvidia-vaapi-driver backend
    __GL_GSYNC_ALLOWED = "1"; # NOTE: nvidia g-sync
    __GL_VRR_ALLOWED = "1"; # NOTE: nvidia g-sync
  };

  # Security configuration
  security.sudo.wheelNeedsPassword = false;

  # Enable SSH daemon
  services.openssh.enable = true;
  
  # Open ports in the firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
