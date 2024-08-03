{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  # https://nixos.wiki/wiki/Chromium#Enabling_native_Wayland_support
  # https://nixos.wiki/wiki/Wayland#Electron_and_Chromium
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # https://wiki.archlinux.org/title/AMDGPU#Monitoring
    amdgpu_top
    #chromium
    config.boot.kernelPackages.cpupower
    curl
    git
    i2c-tools
    # https://github.com/NixOS/nixpkgs/issues/221535#issuecomment-1488836940
    libva-utils
    # https://www.baeldung.com/linux/power-consumption#1-using-lmsensors
    lm_sensors
    lshw
    # https://wiki.archlinux.org/title/AMDGPU#Monitoring
    nvtopPackages.amd
    # openrgb-with-all-plugins
    pciutils
    pmutils
    # https://www.baeldung.com/linux/power-consumption#3-using-powerstat
    powerstat
    powertop
    radeontop
    ryzenadj
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vulkan-tools
    vulkan-loader
    vulkan-headers
    wget
    # what about turbostat and cpupower?
    # https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L126-L127
  ];
}
