{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  hardware.i2c.enable = true;

  hardware.graphics = {
    enable = true;
    # https://discourse.nixos.org/t/what-exactly-does-hardware-opengl-extrapackages-influence/36384
    extraPackages = with pkgs; [
      # amdvlk does not work with Wayland yet as of 2024-08-02:
      # https://github.com/GPUOpen-Drivers/AMDVLK/issues/351#issuecomment-2198425641
      # https://bbs.archlinux.org/viewtopic.php?id=294816
      # https://www.reddit.com/r/kde/comments/18l3owr/comment/ke22onn/
      # https://aur.archlinux.org/packages/zed-preview#comment-977807
      #amdvlk

      rocm-opencl-icd
      # Is vdpau only for nvidia?
      # https://www.reddit.com/r/archlinux/comments/1d5rsni/comment/l71is7q/
      vaapiVdpau
      libvdpau-va-gl
    ];
    # driSupport = true;
    enable32Bit = true;
    # NixOS 24.05 includes Mesa 24.0.7, but I need Mesa 24.1.
    # NixOS 24.05 packages like GDM were compiled against Mesa 24.0.7 and do not work
    # with a different Mesa version, so I can't just set hardware.opengl.package=unstable.mesa.drivers.
    # Adding an overlay where mesa=unstable.mesa would work, but it recompiles half of the world.
    # To avoid all of this, upgrade all of NixOS to unstable.
    # https://www.reddit.com/r/NixOS/comments/g52agx/is_it_possible_to_use_mesa_from_nixosunstable_on/
    # package = pkgs-unstable.mesa.drivers;
    # package32 = pkgs-unstable.pkgsi686Linux.mesa.drivers;
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    #package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      #      amdgpuBusId = "PCI:101:0:0";
      #      nvidiaBusId = "PCI:1:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };

    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "555.58";
      sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
      sha256_aarch64 = pkgs.lib.fakeSha256;
      # openSha256 = pkgs.lib.fakeSha256;
      openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
      settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
      persistencedSha256 = pkgs.lib.fakeSha256;
    };

    # https://www.reddit.com/r/NixOS/comments/1cx9wsy/comment/lanvj9y
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "555.58";
    #   sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
    #   sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
    #   openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
    #   settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M="; #"sha256-m2rNASJp0i0Ez2OuqL+JpgEF0Yd8sYVCyrOoo/ln2a4=";
    #   persistencedSha256 = lib.fakeHash; #"sha256-XaPN8jVTjdag9frLPgBtqvO/goB5zxeGzaTU0CdL6C4=";
    # };
  };

  #services.hardware.openrgb.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
}
