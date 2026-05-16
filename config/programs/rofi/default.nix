{ config, lib, ... }:

let repoPath = "${config.home.homeDirectory}/nixos-configuration"; in
{
  xdg.configFile."rofi/config.rasi".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/rofi/config.rasi";
}
