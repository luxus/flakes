# NixOS configuration for vanessa
{ config, pkgs, lib, ... }:

{
  imports = [
    ./disko.nix
    # Add hardware-configuration.nix when available
    # ./hardware-configuration.nix
  ];

  # System settings
  networking.hostName = "vanessa";

  # Allow unfree packages (needed for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # Home Manager configuration (isolated and easily removable)
  home-manager = {
    # Use the global nixpkgs instance for consistency and performance
    useGlobalPkgs = true;
    # Install packages to /etc/profiles for better integration
    useUserPackages = true;

    # User configurations (isolated in separate files)
    users.luxus = import ./home.nix;

    # Pass system configuration to home-manager modules
    extraSpecialArgs = {
      # osConfig is automatically passed, but we can add more here if needed
    };

    # Plasma-manager module added via flake.nix sharedModules for KDE configuration
  };
  
  # Nix configuration with Determinate Nix enhancements
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Determinate Nix optimizations
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh; # Using zsh as requested
    initialPassword = "password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/AjBtg8D4lMoBkp2L3dDb5EmkOGr1v/Ns1wwRoKds4"
    ];
    # User packages moved to home-manager for better isolation
    # See hosts/vanessa/home.nix for user-specific packages
  };
  
  # Enable zsh system-wide but let home-manager handle user configuration
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    zsh
    # NVIDIA and graphics packages
    cudatoolkit
    # podman-compose
    libva
    libvdpau
    vdpauinfo # NOTE: vdpauinfo
    libva-utils # NOTE: vainfo
    vulkan-tools # NOTE: vulkaninfo
    glxinfo # NOTE: glxinfo and eglinfo
    nvtopPackages.full # NOTE: check GPU usage
    # Determinate Nix tools (if available)
    # Note: determinate-nixd is typically installed via the Determinate installer

    # Essential KDE packages (isolated and easily removable)
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kcolorchooser
    kdePackages.kolourpaint
    kdePackages.ksystemlog
    kdePackages.sddm-kcm
    kdiff3
    kdePackages.partitionmanager
    haruna
    wayland-utils
    wl-clipboard

    # Fonts for Stylix and general use
    jetbrains-mono
    dejavu_fonts
    noto-fonts-emoji
    base16-schemes
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

  # Stylix theming handled at home-manager level to avoid conflicts
  # System-level theming can be added here if needed for bootloader, etc.

  # KDE Plasma 6 Desktop Environment (isolated and easily removable)
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Enable dconf for GTK applications in KDE
  programs.dconf.enable = true;

  # Audio support for KDE
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
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
