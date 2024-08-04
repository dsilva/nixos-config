# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# TODO:
#  - face unlock with Howdy
#  -- https://github.com/LEXUGE/nixos/commits/988190b195a719022dc83daa980d4f98ceed751a/plugins/devices/howdy/packages/howdy.nix
#  - speakers have less bass than on windows
#    -- https://github.com/sammilucia/asus-jamesdsp
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
#    -- https://saveriomiroddi.github.io/Enabling-the-S3-sleep-suspend-on-the-Lenovo-Yoga-7-AMD-Gen-7-and-possibly-others/
#  - UI to manage the GPU MUX switch
#  - check that the boot console uses the AMD iGPU, not the nvidia dGPU
#  - supergfxd?
#  -- https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L78C12-L78C21
#  - what are these additional opengl configs?
#  -- https://github.com/Quoteme/nixos/blob/fbdf92b6eacb7ce212218eb70b12d350786f41d7/hardware/asusROGFlowX13.nix#L94
#  - call asus to switch to a US or UK keyboard
#  - sleep to hibernate
#    -- https://www.worldofbs.com/nixos-framework/#setting-up-hibernate
#    -- https://www.cyberciti.biz/faq/linux-command-to-suspend-hibernate-laptop-netbook-pc/
#    -- https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation
#  - touchpad gestures
#    -- three finger drag
#    -- two finger text selection
#    -- two finger swipe to go back
#    -- two finger pinch to zoom
#  - steam
#  - rog-control-center
#  - manage outer light strip
#  - manage back 3 lights
#  - after waking from suspend, the lock screen isn't focused on the password text input box and there's no keyboard navigation to it
#  - after waking from suspend, gnome power mode goes back to Balanced, even if it was at Power Saver before sleeping
#  - colors are too vibrant / saturated:
#    -- https://www.reddit.com/r/Fedora/comments/1ddhhpi/oversaturated_colors/
#    -- https://forum.garudalinux.org/t/colors-are-washed-out-since-last-updates/36817/9
#    -- https://webkit.org/blog-files/color-gamut/
#    -- https://github.com/libvibrant/vibrantLinux
#  - set battery charge limit to 80% or 90%
#  - check that asus-nb-wmi works:
#    -- https://discordapp.com/channels/725125934759411753/1241113282941685793/1242368699378438204
#    -- lsmod | grep asus
#    -- dmesg | grep asus
#    -- dmesg should not show this: asus-nb-wmi: probe with driver asus-nb-wmi failed with error -17 
#  - check what Nobara provides and apply here
#  - automatic time zone
#    -- https://www.reddit.com/r/NixOS/comments/1411gjs/dynamically_set_the_timezone/
#  - amd pstate epp set wrong
#    -- https://docs.kernel.org/admin-guide/pm/amd-pstate.html#processor-support
#    -- /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference not matching cpupower frequency-info
#    -- https://www.reddit.com/r/archlinux/comments/17qo6lz/powerprofilesdaemon_on_gnome_does_anything/
#  - remove redundant clock from tmux status bar
#  - CPPC support for amd_pstate pending asus bios fix:
#    -- https://bugzilla.kernel.org/show_bug.cgi?id=218686
#    -- https://discord.com/channels/725125934759411753/1265111375903195249/1267789226188079156
#    -- https://web.archive.org/web/20240224060623/https://www.reddit.com/r/linux/comments/15p4bfs/amd_pstate_and_amd_pstate_epp_scaling_driver/

{ config, inputs, pkgs, pkgs-unstable, ... }:

let
  overlay-asus = final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/316538#issuecomment-2143736105
    asusctl = pkgs-unstable.asusctl;
    supergfxctl = pkgs-unstable.supergfxctl;
  };

in
{
  imports = [
    ./asus/zephyrus/ga403/default.nix
    ./boot.nix
    ./environment.nix
    ./hardware.nix
    ./networking.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./system.nix
    ./users.nix
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  console.keyMap = "jp106";

  nixpkgs.config.allowUnfree = true;

  # NixOS service definitions reference packages from nixpkgs.
  # Sometimes they let you override packages, but not always.
  # To use a different version of a package and make sure that
  # services pick up that version, add it to nixpkgs overlays.
  #
  # https://www.reddit.com/r/NixOS/comments/1cgiywn/comment/l1yf3d6/
  # https://discordapp.com/channels/725125934759411753/770379483353055264/1226274730353496108
  nixpkgs.overlays = [ overlay-asus ];

  powerManagement = {
    enable = true;
    powertop = {
      enable = true;
    };
    cpuFreqGovernor = "powersave";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      # in megabytes
      size = 36 * 1024;
    }
  ];

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

  time.timeZone = "Europe/London";

  # virtualisation.waydroid.enable = true;
}
