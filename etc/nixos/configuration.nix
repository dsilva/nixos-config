# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# TODO:
#  - face unlock with Howdy
#  -- https://github.com/LEXUGE/nixos/commits/988190b195a719022dc83daa980d4f98ceed751a/plugins/devices/howdy/packages/howdy.nix
#  - speakers have less bass than on windows
#  - tune speakers (compare with macbook)
#  - gets hot while idle
#  - nvidia drivers
#  - disable gpu for normal use
#  -- https://wiki.archlinux.org/title/NVIDIA_Optimus
#  - brightness slider in gnome not working
#  - brightness keys on keyboard not working
#  - disable keyboard lights
#  - default to boot to linux
#  - upload config to github
#  - ga403ui patch for nixos-hardware repo
#  - check that all keys are mapped correctly in X, Wayland, and tty
#  - alternate keyboard mapping matching UK macbook
#  - touchpad pointer acceleration to match macbook/macos
#  - setup s3 sleep mode instead of modern sleep
#  - UI to manage the GPU MUX switch
#  - check that the boot console uses the AMD iGPU, not the nvidia dGPU
#  - supergfxd?
#  -- https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L78C12-L78C21
#  - what are these additional opengl configs?
#  -- https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L94
#  - call asus to switch to a US or UK keyboard
#  - sleep to hibernate
#  - touchpad gestures
#    -- three finger drag
#    -- two finger text selection
#    -- two finger swipe to go back
#  - steam
#  - rog-control-center
#  - manage outer light strip
#  - manage back 3 lights
#  - after waking from suspend, the lock screen isn't focused on the password text input box and there's no keyboard navigation to it
#  - after waking from suspend, gnome power mode goes back to Balanced, even if it was at Power Saver before sleeping
#  - colors are too vibrant / saturated:
#    -- https://www.reddit.com/r/Fedora/comments/1ddhhpi/oversaturated_colors/
#    -- https://webkit.org/blog-files/color-gamut/
#    -- https://github.com/libvibrant/vibrantLinux
#  - set battery charge limit to 80% or 90%
#  - check that asus-nb-wmi works:
#    -- https://discordapp.com/channels/725125934759411753/1241113282941685793/1242368699378438204
#    -- lsmod | grep asus
#    -- dmesg | grep asus
#    -- dmesg should not show this: asus-nb-wmi: probe with driver asus-nb-wmi failed with error -17 
#  - check what Nobara provides and apply here

{ config, pkgs, pkgs-unstable, ... }:

let
  channel-23-11 = import (builtins.fetchTarball "channel:nixos-23.11") { system = builtins.currentSystem; };
  pkgs-23-11 = channel-23-11.pkgs;
  #channel-unstable = import (builtins.fetchTarball "channel:nixos-unstable") { system = builtins.currentSystem; };
  #pkgs-unstable = channel-unstable.pkgs;
  #pkgs-unstable = import <nixos-unstable> { config.allowUnfree = true; };
  overlay-asus = final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/316538#issuecomment-2143736105
    asusctl = pkgs-unstable.asusctl;
    supergfxctl = pkgs-unstable.supergfxctl;
  };
  
  
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # NixOS service definitions reference packages from nixpkgs.
  # Sometimes they let you override packages, but not always.
  # To use a different version of a package and make sure that
  # services pick up that version, add it to nixpkgs overlays.
  #
  # https://www.reddit.com/r/NixOS/comments/1cgiywn/comment/l1yf3d6/
  # https://discordapp.com/channels/725125934759411753/770379483353055264/1226274730353496108
  nixpkgs.overlays = [ overlay-asus ];

  imports = [
      ./asus/zephyrus/ga403/default.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs-unstable.linuxPackages_latest;
  # https://github.com/NixOS/nixpkgs/blob/9f918d616c5321ad374ae6cb5ea89c9e04bf3e58/pkgs/top-level/linux-kernels.nix#L219
  # We need Linux 6.11 for asus g14 2024 GA403UI support
  # TODO: read about the zen and xanmod kernels
  #boot.kernelPackages = pkgs-unstable.linuxPackages_testing;
  # https://www.reddit.com/r/NixOS/comments/18d3ftz/comment/kcewc4b/
  #boot.kernelPackages = pkgs.linuxPackages_cachyos-rc;

  #boot.kernelPackages =
  #  let
  #    linux-pkg = { fetchgit, fetchurl, buildLinux, ... }@args:

  #      buildLinux (args // rec {
  #        version = "6.11.0-rc1";
  #        modDirVersion = version;
  #        src = fetchurl {
  #          url = "https://git.kernel.org/torvalds/t/linux-6.11-rc1.tar.gz";
  #          sha256 = "sha256-LwEX2frGRkc0LeYAABNv/o4E/rH0kkNfhSRR3ly8dkk=";
  #        };
  #        #kernelPatches = [ ];
  #        #extraConfig = ''
  #        #  INTEL_SGX y
  #        #'';
  #      } // (args.argsOverride or { }));
  #    linux = pkgs.callPackage linux-pkg { };
  #  in pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);
    

  boot.kernelParams = [
    "mem_sleep_default=deep"
    "pcie_aspm.policy=powersupersave"
    # https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
    # If this is set, does the nvidia dGPU turn on for the console in the boot sequence?
    # "nvidia_drm.fbdev=1"

    # Uncomment this if the display flickers:
    # https://github.com/sjhaleprogrammer/nixos/blob/c4f0e7488abd60a280fffd9511809c3261b643c8/configuration.nix#L92
    # https://bbs.archlinux.org/viewtopic.php?id=279300
    # https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html
    "amdgpu.dcdebugmask=0x10"
  ];

  # might be already provided by services.hardware.openrgb.enable=true
  #boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];

  # https://github.com/NixOS/nixpkgs/issues/276374#issuecomment-2000252942
  boot.initrd.systemd.enable = true;
  # https://github.com/NixOS/nixpkgs/pull/282022
  boot.initrd.supportedFilesystems = [ "ext4" "vfat" ];

  powerManagement = {
    enable = true;
    powertop = {
      enable = true;
    };
  };
 
  # 24.11 
  #hardware.graphics.enable = true;
  # 24.05 
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

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
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "555.58";
    sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
    sha256_aarch64 = pkgs.lib.fakeSha256;
    # openSha256 = pkgs.lib.fakeSha256;
    openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
    settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M=";
    persistencedSha256 = pkgs.lib.fakeSha256;
  };

  services.hardware.openrgb.enable = true;

  # https://www.reddit.com/r/NixOS/comments/1cx9wsy/comment/lanvj9y
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
  #   version = "555.58";
  #   sha256_64bit = "sha256-bXvcXkg2kQZuCNKRZM5QoTaTjF4l2TtrsKUvyicj5ew=";
  #   sha256_aarch64 = "sha256-7XswQwW1iFP4ji5mbRQ6PVEhD4SGWpjUJe1o8zoXYRE=";
  #   openSha256 = "sha256-hEAmFISMuXm8tbsrB+WiUcEFuSGRNZ37aKWvf0WJ2/c=";
  #   settingsSha256 = "sha256-vWnrXlBCb3K5uVkDFmJDVq51wrCoqgPF03lSjZOuU8M="; #"sha256-m2rNASJp0i0Ez2OuqL+JpgEF0Yd8sYVCyrOoo/ln2a4=";
  #   persistencedSha256 = lib.fakeHash; #"sha256-XaPN8jVTjdag9frLPgBtqvO/goB5zxeGzaTU0CdL6C4=";
  # };

  services.udev = {
    extraRules = ''
      ${builtins.readFile "${pkgs.openrgb}/lib/udev/rules.d/60-openrgb.rules"}

      # Disable auto-suspend for the ASUS N-KEY Device, i.e. USB Keyboard
      # Otherwise, it will tend to take 1-2 key-presses to wake-up after suspending
      #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/autosuspend}="-1"

    '';
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      # in megabytes
      size = 36*1024;
    }
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  #time.timeZone = "America/New_York";
  time.timeZone = "Europe/London";
  services.automatic-timezoned.enable = true;


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;

    # keymap
    xkb = {
      layout = "jp";
      variant = "";
    };
    
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    videoDrivers = ["nvidia" "modeset"];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
    };
  };


  # Configure console keymap
  console.keyMap = "jp106";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  #nix.gc.automatic = true;
  nix.settings.auto-optimise-store = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.daniel = {
    isNormalUser = true;
    description = "Daniel";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #chromium
    curl
    git
    #google-chrome
    i2c-tools
    lshw
    openrgb-with-all-plugins
    pciutils
    pmutils
    powertop
    radeontop
    ryzenadj
    #steam
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vulkan-tools
    vulkan-loader
    vulkan-headers
    wget
    # what about turbostat and cpupower?
    # https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L126-L127
  ];

  #programs.rog-control-center.enable = true;

  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    #dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    #localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  hardware.i2c.enable = true;

  # Adds the missing asus functionality to Linux.
  # https://asus-linux.org/manual/asusctl-manual/
  services.asusd = {
    enable = true;
    enableUserService = true;
    # fanCurvesConfig = builtins.readFile ../config/fan_curves.ron;

    # https://github.com/NixOS/nixpkgs/issues/316538#issuecomment-2143736105
    #package = pkgs-23-11.asusctl;
  };
  services.supergfxd.enable = true;
  # AMD has better battery life with PPD over TLP:
  # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;

  # protectKernelImage blocks hibernate.  Don't do that.
  # https://discourse.nixos.org/t/hibernate-doesnt-work-anymore/24673/5
  # https://discourse.nixos.org/t/solved-nohibernate-option-added-to-kernelparams-and-i-dont-know-where-it-comes-from/20611/5
  # https://github.com/NixOS/nixpkgs/commit/84fb8820db6226a6e5333813d47da6d876243064 
  security.protectKernelImage = false;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-24.05/";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = 
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
