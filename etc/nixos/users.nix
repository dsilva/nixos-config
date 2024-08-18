{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = "Daniel";
    extraGroups = [
      # https://github.com/NixOS/nixpkgs/issues/317013
      config.programs.ydotool.group
      # needed for fusuma
      "input"
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
}
