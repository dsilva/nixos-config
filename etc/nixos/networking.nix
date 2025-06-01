{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall = {
    enable = false;
    # 51820 UDP for WireGuard
    # https://nixos.wiki/wiki/WireGuard
    # more ports for DLNA:
    # https://github.com/NixOS/nixpkgs/blob/a0d6390cb3e82062a35d0288979c45756e481f60/nixos/modules/services/networking/minidlna.nix
    # https://github.com/NixOS/nixpkgs/blob/a0d6390cb3e82062a35d0288979c45756e481f60/nixos/modules/services/networking/avahi-daemon.nix
    # 49152 for gerbera
    allowedUDPPorts = [ 49152 51820 ];
    allowedTCPPorts = [ 49152 51820 ];
  };

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;
}
