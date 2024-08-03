{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  # protectKernelImage blocks hibernate.  Don't do that.
  # https://discourse.nixos.org/t/hibernate-doesnt-work-anymore/24673/5
  # https://discourse.nixos.org/t/solved-nohibernate-option-added-to-kernelparams-and-i-dont-know-where-it-comes-from/20611/5
  # https://github.com/NixOS/nixpkgs/commit/84fb8820db6226a6e5333813d47da6d876243064 
  security.protectKernelImage = false;

  security.rtkit.enable = true;
}
