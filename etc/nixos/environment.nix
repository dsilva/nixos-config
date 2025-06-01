{ config, inputs, lib, pkgs, pkgs-unstable, ... }:

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
    fusuma
    git
    i2c-tools
    iptables
    libinput
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
    wireguard-tools
    # https://github.com/iberianpig/fusuma/issues/173#issuecomment-2058984377
    ydotool
    # what about turbostat and cpupower?
    # https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L126-L127
  ];

  environment.variables = {
    # https://discourse.nixos.org/t/24-11-amd-gpu-how-to-use-mesa-radv-instead-of-amdvlk/57110/5
    # https://git.eisfunke.com/config/nixos/-/blob/38424e545e4555c0a87e9e72ba76c7d4d3d6cc38/docs/graphics.md#vdpau
    VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "radeonsi");
  };
}
