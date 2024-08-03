{ config, inputs, pkgs, pkgs-unstable, ... }:

let
  # flukejones's kernel with asus patches that are still making their way to linuux 6.11
  # https://discord.com/channels/725125934759411753/747539974555172934/1262873770041802963 
  # https://lore.kernel.org/platform-driver-x86/20240716051612.64842-1-luke@ljones.dev/T/#t
  linux-flukejones =
    let
      linux-pkg = { fetchgit, fetchFromGitLab, fetchurl, buildLinux, ... }@args:
        buildLinux (args // rec {
          version = "6.10.0-rc7";
          modDirVersion = version;
          src = fetchFromGitLab {
            owner = "flukejones";
            repo = "linux";
            # Find the latest commit at:
            # https://gitlab.com/flukejones/linux/-/commits/asus-next-stable/?ref_type=HEADS
            rev = "fe7bfa99bba334521dad63e1d71ef5f0bcc65a72";
            sha256 = "sha256-nwZ9zMWE7P9FM1ZOONF9t8Zbh3xgPqdosmtXtO7s6H4=";
          };
          kernelPatches = [
            pkgs.kernelPatches.bridge_stp_helper
            pkgs.kernelPatches.request_key_helper
          ];
          #kernelPatches = [ ];
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
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.loader.systemd-boot.enable = true;

  # https://github.com/NixOS/nixpkgs/pull/282022
  boot.initrd.supportedFilesystems = [ "ext4" "vfat" ];
  # https://github.com/NixOS/nixpkgs/issues/276374#issuecomment-2000252942
  boot.initrd.systemd.enable = true;

  # might be already provided by services.hardware.openrgb.enable=true
  # boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;

  # https://github.com/NixOS/nixpkgs/blob/9f918d616c5321ad374ae6cb5ea89c9e04bf3e58/pkgs/top-level/linux-kernels.nix#L219
  # We need Linux 6.11 for asus g14 2024 GA403UI support:
  #   https://gitlab.com/asus-linux/asusctl/-/issues/484
  #   https://discord.com/channels/725125934759411753/1265261799637389424/1265273875638517841 
  # TODO: read about the zen and xanmod kernels
  #boot.kernelPackages = pkgs-unstable.linuxPackages_testing;
  # https://www.reddit.com/r/NixOS/comments/18d3ftz/comment/kcewc4b/
  #boot.kernelPackages = pkgs.linuxPackages_cachyos-rc;

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
