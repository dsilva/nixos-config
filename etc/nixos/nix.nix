{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  #nix.gc.automatic = true;

  # Is this already the default as of NixOS 24.05?
  # nix.nixPath = [ "nixpkgs=flake:nixpkgs" "/nix/var/nix/profiles/per-user/root/channels" ];

  # Is this already the default as of NixOS 24.05?
  # nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };
}
