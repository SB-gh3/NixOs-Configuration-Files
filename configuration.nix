# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader and Kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Automatic Garbage Collecting
  boot.loader.systemd-boot.configurationLimit = 25;

  nix.gc =
  {
    automatic = true;
    dates = "weekly";
    options = "-d";
    persistent = true;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the KDE Plasma 6 Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  #Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #Enable Flatpak
  services.flatpak.enable = true;

  systemd.services.flatpak-repo =
  {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire =
  {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.spencerb =
  {
    isNormalUser = true;
    description = "Spencer Bailey";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "docker" ];
    packages = with pkgs;
    [
      #kdePackages.kate
      #thunderbird
    ];
  };

  #Automount drives on startup
  fileSystems."/mnt/Games" = 
  {
    device = "UUID=32d18297-49ec-4c60-82c9-92ae6f4b8e0d"; #UUID
    fsType = "ext4"; 
    options = [ "nofail" "x-systemd.before=local-fs.target" ];
  };

  fileSystems."/mnt/Extra Games" = 
  {
    device = "UUID=4fdbb1b8-3ce3-4515-a984-3cda497e801d";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.before=local-fs.target" ];
  };

  fileSystems."/mnt/SSD Games" = 
  {
    device = "UUID=60da2b36-318b-4530-ba0c-03fee4280706";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.before=local-fs.target" ];
  };

  #Set Trusted User
  nix.extraOptions = ''trusted-users = root spencerb'';

  #KDE Plasma Excludes
  environment.plasma6.excludePackages = with pkgs.libsForQt5;
  [
    konsole
    kate
  ];

  #Remove Sudo Password
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #Install Nvidia Drivers
  nixpkgs.config.nvidia.acceptLicense = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.variables =
  {
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  #Enable Hyprland
  programs.hyprland.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
  [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    fastfetch
    google-chrome
    vscode-fhs
    vulkan-loader
    vulkan-validation-layers
    vulkan-tools
    steam
    jdk
    wineWowPackages.full
    winetricks
    easyeffects
    lolcat
    rustdesk-flutter
    btop
    tmux
    blackbox-terminal
    lf
    godot_4
    yt-dlp
    git
    distrobox
    nix-direnv
    rustup
    go
    pkg-config
    gopls
    gnuplot
    vlc
    socat
    quickemu
    protontricks
    rustdesk-server
    libreoffice
    util-linux
    cudatoolkit
    gnumake
    libgcc
    gnat14
    getopt
    flex
    bison
    bc
    binutils
    cudaPackages.cuda_nvcc
    gparted
    obs-studio
    inkscape-with-extensions
    gimp-with-plugins
    ghostty
    cmake
    libGLU
    kdePackages.xdg-desktop-portal-kde
    hyprland
    kitty
  ];

  #Install Nvidia Drivers
  hardware =
  {
    nvidia =
    {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaSettings = true;
    };
    graphics =
    {
      enable32Bit = true;
      extraPackages = with pkgs;
      [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  #CUDA support
  nixpkgs.config.cudaSupport = true;
  nixpkgs.config.cudaCapabilities = [ "8.9" ];

  #Enable Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless =
  {
    enable = true;
    setSocketVariable = true;
  };

  #Enables support for SANE scanners
  hardware.sane.enable = true;

  #Firmware stuff - not entirely sure
  hardware.enableRedistributableFirmware = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
