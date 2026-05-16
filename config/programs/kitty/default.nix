{ config, ... }:

let repoPath = "${config.home.homeDirectory}/nixos-configuration"; in
{
  xdg.configFile."kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${repoPath}/config/programs/kitty";
}
