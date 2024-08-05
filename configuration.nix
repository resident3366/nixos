# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Auto upgrade
  system.autoUpgrade.enable = true;
   
   programs.hyprland.enable = true;
   xdg.portal.enable = true;
   xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
   
  # Suspend after 30 minutes
  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30min
  '';

  # Hint for electron apps to use wayland
  environment.sessionVariables = {
   NIXOS_OZONE_WL = "1";
};

   # Fonts
  fonts = {
   packages = with pkgs; [
     noto-fonts
     noto-fonts-cjk
     font-awesome
     poppins
     source-han-sans
     source-han-sans-japanese
     source-han-serif-japanese
  ];
  fontconfig.defaultFonts = {
   serif = [ "Noto Serif" "Source Han Serif" ];
   sansSerif = [ "Poppins" "Noto Sans" "Source Han Sans" ];
   };
};

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  # Configure keymap in X11
  #services.xserver = {
  #  layout = "us";
  #  xkbVariant = "";
  #};

  # X11 Keymap & Layout
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "";
 

  # Enable 3D Stuff
  hardware.graphics.enable32Bit = true;
  hardware.graphics.enable = true;

  # Enable AMD Driver
  services.xserver.videoDrivers = ["amdgpu"];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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
  users.users.redacted = {
    isNormalUser = true;
    description = "redacted";
    extraGroups = [ "networkmanager" "wheel" "openrazer" "power" "video" "realtime" "gamemode" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  users.groups.realtime = { };

  # Auto Login
  services.greetd = {
   enable = true;
    settings = {
     default_session = {
       command = "Hyprland";
       user = "redacted";
     };
   };
  vt = 7;
};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim
  wget
  wowup-cf
  starship
  discord
  mangohud
  protonup
  brave
  lutris
  heroic
  radeontop
  curl
  jq
  wireguard-tools
  openvpn
  git
  fastfetch
  openrazer-daemon
  razergenie
  waybar
  kitty
  wofi
  pavucontrol
  zip
  unzip
  nwg-look
  dracula-icon-theme
  dracula-theme
  hyprpaper
  dunst
  libnotify
  networkmanagerapplet
  grim
  slurp
  wl-clipboard
  lf
  imagemagick
  hyprlock
  hypridle
  colorls
  stow
  ];

  # Enable Steam
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode = {
   enable = true;
   enableRenice = true;
     settings = {
       general = {
         softrealtime = "auto";
         renice = 10;
        };
      };
    }; 
  programs.gamescope.capSysNice = true;

  # Razer
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "redacted" ];

  # Allow realtime prio for user apps
  #security.pam.loginLimits = [
  #  {  domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  #];

  services.udev.extraRules = ''
     KERNEL=="cpu_dma_latency", GROUP="realtime"
  '';
  security.pam.loginLimits = [
   {
     domain = "@realtime";
     type = "-";
     item = "rtprio";
     value = 98;
   }
   {
     domain = "@realtime";
     type = "-";
     item = "memlock";
     value = "unlimited";
   }
   {
     domain = "@realtime";
     type = "-";
     item = "nice";
     value = "-11";
   }
  ];
 
 # Take out the Trash
  nix.gc = {
   automatic = true;
   dates = "weekly";
   options = "--delete-older-than 7d";
};
 
 # Auto optimise store
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "01:30" ];
 
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
  system.stateVersion = "23.05"; # Did you read the comment?

}
