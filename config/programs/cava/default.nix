{ config, pkgs, lib, ... }:

let
  repoPath = "${config.home.homeDirectory}/nixos-configuration";

  # Wrapper that merges the static base config with matugen's runtime colors
  # before launching the real cava binary.
  cava-dynamic = pkgs.writeShellScriptBin "cava" ''
    mkdir -p ~/.config/cava
    cat ~/.config/cava/config_base ~/.config/cava/colors \
      > ~/.config/cava/config 2>/dev/null
    exec ${pkgs.cava}/bin/cava "$@"
  '';
in
{
  home.packages = [ (lib.hiPrio cava-dynamic) ];

  xdg.configFile."cava/config_base".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/cava/config";
}
