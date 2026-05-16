{ config, pkgs, lib, ... }:

let repoPath = "${config.home.homeDirectory}/nixos-configuration"; in
{
  xdg.configFile."matugen".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/matugen";
}
