{ config, pkgs, ... }:

let repoPath = "${config.home.homeDirectory}/nixos-configuration"; in
{
  programs.zsh = {
    enable               = true;
    enableCompletion     = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size           = 10000;
      path           = "$HOME/.zsh_history";
      ignoreAllDups  = true;
    };

    initContent = builtins.readFile ./zsh-init.sh;

    shellAliases = {
      edit     = "sudo -E nvim -n";
      gitavail = "ssh-add $HOME/Documents/Важное/recovery_keys/GitHub/github_remote_keys/key";
      # Rebuild from the repo using the flake — no longer assumes /etc/nixos
      update   = "sudo nixos-rebuild switch --flake ${repoPath}#ilyamiro";
      stop     = "shutdown now";
      edconf   = "sudo -E nvim ${repoPath}/configuration.nix";
      out      = "loginctl terminate-user ilyamiro";
    };

    oh-my-zsh = {
      enable  = true;
      plugins = [ "git" ];
      theme   = "robbyrussell";
    };
  };

  # Convenience shell variables pointing at the live repo checkout
  home.sessionVariables = {
    hypr     = "${repoPath}/config/sessions/hyprland/";
    programs = "${repoPath}/config/programs";
  };
}
