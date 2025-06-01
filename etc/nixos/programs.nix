{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  programs.firefox.enable = true;

  #programs.rog-control-center.enable = true;

  # programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    #localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # https://discourse.nixos.org/t/anyone-got-ydotool-working-in-kde-plasma/19252
  # https://github.com/iberianpig/fusuma/issues/173#issuecomment-2058984377
  # https://mynixos.com/nixpkgs/option/programs.ydotool.enable
  programs.ydotool.enable = true;
}