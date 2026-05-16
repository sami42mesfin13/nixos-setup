{ config, pkgs, lib, ... }:

# All /etc/nixos paths replaced with ~/nixos-configuration (where you clone the repo).
# The repoPath variable is derived from $HOME so it works for any username.
let
  repoPath = "${config.home.homeDirectory}/nixos-configuration";
in
{
  imports = [ ./hypridle.nix ];

  wayland.windowManager.hyprland = {
    enable      = true;
    # Source the hyprland.conf from the live symlink in ~/.config/hypr/
    extraConfig = ''
      source = ${config.home.homeDirectory}/.config/hypr/hyprland.conf
    '';
  };

  home.packages = with pkgs; [
    rofi
    pavucontrol
    fortune
    wl-screenrec
    alsa-utils
    swww
    networkmanager_dmenu
    wl-clipboard
    fd
    qt6.qtmultimedia
    qt6.qt5compat
    qt6.qtwebsockets
    qt6.qtwebengine
    ripgrep
    gtk3
    cava
    cliphist
    tree
    jq
    socat
    pamixer
    brightnessctl
    acpi
    iw
    bluez
    libnotify
    networkmanager
    lm_sensors
    bc
    pulseaudio
    ladspaPlugins
    ladspa-sdk
    imagemagick
  ];

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Symlink the scripts folder so they can be edited without rebuilding
  home.file.".config/hypr/scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/sessions/hyprland/scripts";

  # Symlink hyprland.conf itself (sourced from extraConfig above)
  home.file.".config/hypr/hyprland.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/sessions/hyprland/hyprland.conf";

  # Copy (not symlink) the split config files so Hyprland can write to them
  home.activation.copyHyprConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rsync}/bin/rsync -a --update \
      ${repoPath}/config/sessions/hyprland/config/ \
      $HOME/.config/hypr/config/
    chmod -R u+w $HOME/.config/hypr/config
  '';

  home.activation.copyHyprTemplates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rsync}/bin/rsync -a --update \
      ${repoPath}/config/sessions/hyprland/templates/ \
      $HOME/.config/hypr/templates/
    chmod -R u+w $HOME/.config/hypr/templates
  '';
}
