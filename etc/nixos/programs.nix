{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  programs.firefox.enable = true;

  #programs.rog-control-center.enable = true;

  # programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
  programs.ssh.askPassword = "${pkgs.ksshaskpass}/bin/ksshaskpass";

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    #localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}