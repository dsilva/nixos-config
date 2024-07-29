{ lib, ... }:

{
  imports = [
    <nixos-hardware/common/cpu/amd>
    <nixos-hardware/common/cpu/amd/pstate.nix>
    <nixos-hardware/common/gpu/nvidia>
    <nixos-hardware/common/gpu/nvidia/prime.nix>
    <nixos-hardware/common/pc/laptop>
    <nixos-hardware/common/pc/laptop/acpi_call.nix>
    <nixos-hardware/common/pc/ssd>
    <nixos-hardware/common/hidpi.nix>
    # <nixos-hardware/asus/battery.nix>
  ];

  hardware.nvidia.prime = {
      amdgpuBusId = "PCI:101:0:0";
      nvidiaBusId = "PCI:1:0:0";
  };

  # Needed for desktop environments to detect/manage display brightness
  hardware.sensor.iio.enable = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;

}

