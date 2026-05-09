{ config, inputs, pkgs, pkgs-unstable, ... }:

let
  # flukejones's kernel with asus patches that are still making their way to linuux 6.11
  # https://discord.com/channels/725125934759411753/747539974555172934/1262873770041802963 
  # https://lore.kernel.org/platform-driver-x86/20240716051612.64842-1-luke@ljones.dev/T/#t
  linux-flukejones =
    let
      fluke-linux-versions = {
        # Find the latest commit at one of the branches listed below:

        # https://github.com/flukejones/linux/commits/asus-next-stable/
        "6.12.1-2024-11-22" = {
          rev = "3c43651ca05d57e6e7da74fa691bd9419081d17f";
          sha256 = "sha256-Qon7LJD3LFQwQh6BTtVVWf9/Yb0ueu+sNK8dl0gJrl4=";
          version = "6.12.1";
        };
        # https://github.com/flukejones/linux/commits/wip/ally-6.14/
        "6.14.0-rc7-2025-03-16" = {
          rev = "4f166a6bf9cb7d2b6118cf508c393a4d5d087158";
          sha256 = "sha256-L+1aerYyF1x2BaFuKIRy9/XTA1rf+cwuPJ/+CbQ9N/U=";
          version = "6.14.0-rc7";
        };
      };
      fluke-linux-version = fluke-linux-versions."6.14.0-rc7-2025-03-16";
      linux-pkg = { fetchgit, fetchFromGitLab, fetchFromGitHub, fetchurl, buildLinux, ... }@args:
        buildLinux (args // rec {
          version = fluke-linux-version.version;
          modDirVersion = version;
          # src = fetchFromGitLab {
          #   owner = "flukejones";
          #   repo = "linux";
          #   # Find the latest commit at:
          #   # https://gitlab.com/flukejones/linux/-/commits/asus-next-stable/?ref_type=HEADS
          #   rev = "5ef1e51e585133cfa1f4cd57ba33071fee574ae4";
          #   sha256 = "sha256-z0JesQOl5l8+UxQQlyPCfUfS99Aqf3raQBeTMF7ESrw=";
          # };
          src = fetchFromGitHub {
            owner = "flukejones";
            repo = "linux";
            rev = fluke-linux-version.rev;
            sha256 = fluke-linux-version.sha256;
          };
          kernelPatches = [
            pkgs.kernelPatches.bridge_stp_helper
            pkgs.kernelPatches.request_key_helper
          ];
          #kernelPatches = [ ];
          # The CS35L56 Cirrus Amp in the 2024 Zephyrus G14 (GA403U) requires
          # CONFIG_SERIAL_MULTI_INSTANTIATE to be enabled in order for it to fire up and load its firmware
          # https://forums.gentoo.org/viewtopic-p-8826740.html?sid=642d536a66748c0bb0aced2ec01dade4#8826740
          #extraConfig = ''
          #  INTEL_SGX y
          #'';
        } // (args.argsOverride or { }));
      linux = pkgs.callPackage linux-pkg { };
    in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);

  linux-6-11-rc1 =
    let
      linux-pkg = { fetchgit, fetchurl, buildLinux, ... }@args:
        buildLinux (args // rec {
          version = "6.11.0-rc1";
          modDirVersion = version;
          src = fetchurl {
            url = "https://git.kernel.org/torvalds/t/linux-6.11-rc1.tar.gz";
            sha256 = "sha256-LwEX2frGRkc0LeYAABNv/o4E/rH0kkNfhSRR3ly8dkk=";
          };
          #kernelPatches = [ ];
          #extraConfig = ''
          #  INTEL_SGX y
          #'';
        } // (args.argsOverride or { }));
      linux = pkgs.callPackage linux-pkg { };
    in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);

in

{
  # boot.consoleLogLevel = 0;

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.systemd-boot.enable = true;

  # https://github.com/NixOS/nixpkgs/pull/282022
  boot.initrd.supportedFilesystems = [ "ext4" "vfat" ];
  # https://github.com/NixOS/nixpkgs/issues/276374#issuecomment-2000252942
  boot.initrd.systemd.enable = true;

  # might be already provided by services.hardware.openrgb.enable=true
  # boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  # If the nvidia driver fails to build, use the default LTS kernel
  # https://discourse.nixos.org/t/cannot-build-nvidia-x11-570-153-02-6-15/64898/5
  #boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_unstable;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #boot.kernelPackages = pkgs.linuxPackagesFor pkgs-unstable.linux_latest;


#boot.kernelPackages = pkgs.linuxPackagesFor (pkgs-unstable.linux_latest.overrideAttrs (old: {
#    # This manually merges the kernel and its modules so the 
#    # stable NixOS modules can find them in the old location.
#    passthru = (old.passthru or {}) // {
#      modules = pkgs-unstable.linux_latest.modules;
#    };
#  }));

  # https://github.com/NixOS/nixpkgs/blob/9f918d616c5321ad374ae6cb5ea89c9e04bf3e58/pkgs/top-level/linux-kernels.nix#L219
  # We need Linux 6.11 for asus g14 2024 GA403UI support:
  #   https://gitlab.com/asus-linux/asusctl/-/issues/484
  #   https://discord.com/channels/725125934759411753/1265261799637389424/1265273875638517841 
  # TODO: read about the zen and xanmod kernels
  # boot.kernelPackages = pkgs-unstable.linuxPackages_testing;
  # https://www.reddit.com/r/NixOS/comments/18d3ftz/comment/kcewc4b/
  #boot.kernelPackages = pkgs.linuxPackages_cachyos-rc;

  # boot.kernelPackages = linux-flukejones;

  boot.kernelParams = [
    # AMD Adaptive Backlight Management
    # Potentially reduces power usage.  Comment out if it's annoying.
    # https://community.frame.work/t/adaptive-backlight-management-abm/41055
    # https://gitlab.freedesktop.org/upower/power-profiles-daemon#panel-power-savings
    # "amdgpu.abmlevel=3"

    # Uncomment this if the display flickers:
    # https://github.com/sjhaleprogrammer/nixos/blob/c4f0e7488abd60a280fffd9511809c3261b643c8/configuration.nix#L92
    # https://bbs.archlinux.org/viewtopic.php?id=279300
    # https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html
    # "amdgpu.dcdebugmask=0x10"

    # Uncomment this if the display flickers white when changing resolutio or connecting an external monitor:
    # https://wiki.archlinux.org/title/AMDGPU#Screen_flickering_white_when_using_KDE
    # "amdgpu.sg_display=0"

    # https://wiki.archlinux.org/title/CPU_frequency_scaling#Scaling_drivers
    # "amd_pstate=passive"

    "boot.shell_on_fail"
    "mem_sleep_default=deep"
    "quiet"
    "pcie_aspm.policy=powersupersave"
    "splash"

    # https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
    # If this is set, does the nvidia dGPU turn on for the console in the boot sequence?
    # "nvidia_drm.fbdev=1"
  ];

  boot.plymouth = {
    enable = true;
    theme = "fade-in";
    themePackages = with pkgs; [
      # By default we would install all themes
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "abstract_ring" ];
      })
    ];
  };
}
