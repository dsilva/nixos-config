{ lib, nixos-hardware, ... }:

{
  imports = [
    nixos-hardware.nixosModules.common-cpu-amd
    # https://wiki.archlinux.org/title/CPU_frequency_scaling#amd_pstate
    # https://docs.kernel.org/admin-guide/pm/amd-pstate.html
    # CPPC and thus pstate + EPP support is broken on asus ga403ui and ga403uv bios v306:
    # https://bugzilla.kernel.org/show_bug.cgi?id=218686
    # https://discord.com/channels/725125934759411753/1265111375903195249
    # nixos-hardware.nixosModules.common-cpu-amd-pstate
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-gpu-nvidia
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-acpi_call
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-hidpi
    # nixos-hardware.nixosModules.asus-battery

#    <nixos-hardware/common/cpu/amd>
#    <nixos-hardware/common/cpu/amd/pstate.nix>
#    <nixos-hardware/common/gpu/nvidia>
#    <nixos-hardware/common/gpu/nvidia/prime.nix>
#    <nixos-hardware/common/pc/laptop>
#    <nixos-hardware/common/pc/laptop/acpi_call.nix>
#    <nixos-hardware/common/pc/ssd>
#    <nixos-hardware/common/hidpi.nix>
#    # <nixos-hardware/asus/battery.nix>
  ];

  hardware.nvidia.prime = {
      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
  };

  # Needed for desktop environments to detect/manage display brightness
  hardware.sensor.iio.enable = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;

}

