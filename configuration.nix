# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

# 'self' is the flake root — injected via specialArgs in flake.nix.
# It lets us reference files in the repo without hardcoding /etc/nixos.
{ config, pkgs, lib, self, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # home-manager is wired in via flake.nix — no channel import needed here.
  ];

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    wget
    taskwarrior3
    inotify-tools
    lavat
    file
    pipes
    glaxnimate
    clock-rs
    cbonsai
    git
    killall
    btop
    mpv
    zenity
    matugen
    gpu-screen-recorder
    neovim
    fzf
    inkscape
    direnv
    zbar
    python311
    ffmpeg
    # python314 does not exist in nixpkgs — replaced with python312.
    python312
    (wrapFirefox (pkgs.firefox-unwrapped.override { pipewireSupport = true; }) {})
    telegram-desktop
    pkgs.onlyoffice-desktopeditors
    kitty
    libreoffice-qt
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
    obsidian
    obs-studio
    p7zip
    papers
    fastfetch
    jetbrains.idea-community
    quickshell
    gnome-shell-extensions
    grim
    playerctl
    satty
    yq-go
    xdg-desktop-portal-gtk
    eww
    swappy
    slurp
    mpvpaper
    gnome-tweaks
    # pkgsCross.mingwW64.stdenv.cc pulls gigabytes of cross-toolchain and is
    # almost never in the binary cache. Uncomment only if you need it.
    # pkgsCross.mingwW64.stdenv.cc
    wmctrl
    bottles
    qbittorrent
    power-profiles-daemon
    jdk8
    steam-run
  ];

  environment.pathsToLink = [ "/share/gsettings-schemas" ];

  # ---------------------------------------------------------------------------
  # Users
  # ---------------------------------------------------------------------------
  users.users.ilyamiro = {
    isNormalUser  = true;
    description   = "ilyamiro";
    extraGroups   = [ "networkmanager" "wheel" "video" "adbusers" "libvirtd" ];
    useDefaultShell = true;
    shell         = pkgs.zsh;
  };

  users.defaultUserShell = pkgs.zsh;
  system.userActivationScripts.zshrc = "touch .zshrc";

  security.sudo.extraRules = [
    {
      users = [ "ilyamiro" ];
      commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ];
    }
  ];

  services.logind.settings.Login.HandlePowerKey = "ignore";

  # ---------------------------------------------------------------------------
  # Programs
  # ---------------------------------------------------------------------------
  programs.zsh.enable       = true;
  programs.adb.enable       = true;
  programs.firefox.enable   = true;
  programs.dconf.enable     = true;
  programs.gamemode.enable  = true;
  programs.virt-manager.enable = true;

  programs.steam = {
    enable                    = true;
    remotePlay.openFirewall   = true;
    dedicatedServer.openFirewall = true;
  };

  # ---------------------------------------------------------------------------
  # Desktop / display
  # ---------------------------------------------------------------------------
  services.xserver.enable             = true;
  services.displayManager.gdm.enable  = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable            = true;

  xdg.portal = {
    enable       = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };

  services.xserver.xkb = { layout = "us,ru"; variant = ""; };

  # ---------------------------------------------------------------------------
  # Fonts
  # ---------------------------------------------------------------------------
  fonts.packages = with pkgs; [ udev-gothic-nf noto-fonts liberation_ttf ];
  fonts.fontconfig = {
    enable         = true;
    hinting.style  = "slight";
    subpixel.rgba  = "rgb";
  };

  # ---------------------------------------------------------------------------
  # Services
  # ---------------------------------------------------------------------------
  services.flatpak.enable            = true;
  services.blueman.enable            = true;
  services.printing.enable           = true;
  services.openssh.enable            = true;
  services.power-profiles-daemon.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable           = true;
    alsa.enable      = true;
    alsa.support32Bit = true;
    pulse.enable     = true;
  };

  # ---------------------------------------------------------------------------
  # Networking & locale
  # ---------------------------------------------------------------------------
  networking.hostName = "ilyamiro";
  networking.networkmanager = { enable = true; wifi.powersave = false; };

  time.timeZone       = "Europe/Copenhagen";
  i18n.defaultLocale  = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # ---------------------------------------------------------------------------
  # Nix settings
  # ---------------------------------------------------------------------------
  nixpkgs.config.allowUnfree        = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = { automatic = true; dates = "daily"; options = "--delete-older-than 14d"; };

  # ---------------------------------------------------------------------------
  # Boot & Plymouth
  # ---------------------------------------------------------------------------
  boot = {
    plymouth = {
      enable = true;
      theme  = "simple";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname   = "plymouth-theme-simple";
          version = "1.0";
          # Use self (the flake root) instead of the hardcoded /etc/nixos path.
          # This works no matter where the repo is checked out.
          src = "${self}/config/programs/plymouth/simple";
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/simple
            cp -r * $out/share/plymouth/themes/simple/
            substituteInPlace $out/share/plymouth/themes/simple/simple.plymouth \
              --replace "@out@" "$out"
          '';
        })
      ];
    };

    consoleLogLevel  = 0;
    initrd.verbose   = false;
    kernelParams     = [
      "quiet" "splash" "boot.shell_on_fail"
      "loglevel=3" "rd.systemd.show_status=false"
      "rd.udev.log_level=3" "udev.log_priority=3"
      "amd_pstate=active" "tsc=reliable" "asus_wmi"
    ];
  };

  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages                  = pkgs.linuxPackages_latest;
  boot.kernelModules                   = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc"          = "fq";
    "net.core.wmem_max"               = 1073741824;
    "net.core.rmem_max"               = 1073741824;
    "net.ipv4.tcp_rmem"               = "4096 87380 1073741824";
    "net.ipv4.tcp_wmem"               = "4096 87380 1073741824";
  };

  # ---------------------------------------------------------------------------
  # Hardware
  # ---------------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true;
  powerManagement.cpuFreqGovernor  = "performance";

  hardware.graphics = {
    enable      = true;
    enable32Bit = true; # needed by Steam / CS2
  };

  # ---------------------------------------------------------------------------
  # NVIDIA (hybrid laptop — AMD iGPU + NVIDIA dGPU)
  # ⚠ Change the Bus IDs below to match YOUR machine.
  #   Run:  lspci | grep -E "VGA|3D"
  #   then convert  01:00.0  ->  PCI:1:0:0
  # ---------------------------------------------------------------------------
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable           = true;
    powerManagement.enable       = false;
    powerManagement.finegrained  = true;
    open                         = false;
    nvidiaSettings               = true;
    package                      = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable             = true;
      offload.enableOffloadCmd   = true;
      nvidiaBusId                = "PCI:1:0:0"; # change me
      amdgpuBusId                = "PCI:4:0:0"; # change me
    };
  };

  # ---------------------------------------------------------------------------
  # Virtualisation
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd.enable = true;

  # ---------------------------------------------------------------------------
  # State version
  # "25.11" is not a real NixOS release (releases are .05 and .11 by year).
  # Set this to the release you actually installed with and NEVER change it.
  # ---------------------------------------------------------------------------
  system.stateVersion = "25.05";
}
