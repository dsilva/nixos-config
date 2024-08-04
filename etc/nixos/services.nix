{ config, inputs, pkgs, pkgs-unstable, ... }:

# let
#   nextdns-id = builtins.readFile "/etc/nixos/nextdns-id";
# in

{
  services.acpid.enable = true;

  # Adds the missing asus functionality to Linux.
  # https://asus-linux.org/manual/asusctl-manual/
  # Issues: https://gitlab.com/asus-linux/asusctl/-/issues
  services.asusd = {
    enable = true;
    enableUserService = true;
    # fanCurvesConfig = builtins.readFile ../config/fan_curves.ron;

    # https://github.com/NixOS/nixpkgs/issues/316538#issuecomment-2143736105
    #package = pkgs-23-11.asusctl;
  };

  # services.automatic-timezoned.enable = true;

  services.desktopManager.plasma6 = {
    enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable sound with pipewire.
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

  # AMD has better battery life with PPD over TLP:
  # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
  services.power-profiles-daemon.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # NextDNS
  # services.resolved = {
  #   enable = true;
  #   extraConfig = ''
  #     [Resolve]
  #     DNS=45.90.28.0#${nextdns-id}.dns.nextdns.io
  #     DNS=2a07:a8c0::#${nextdns-id}.dns.nextdns.io
  #     DNS=45.90.30.0#${nextdns-id}.dns.nextdns.io
  #     DNS=2a07:a8c1::#${nextdns-id}.dns.nextdns.io
  #     DNSOverTLS=yes
  #   '';
  # };

  services.supergfxd.enable = true;

  services.udev = {
    extraRules =
      #  (builtins.readFile "${pkgs.openrgb}/lib/udev/rules.d/60-openrgb.rules") +
      ''

      # Disable auto-suspend for the ASUS N-KEY Device, i.e. USB Keyboard
      # Otherwise, it will tend to take 1-2 key-presses to wake-up after suspending
      #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{idVendor}=="0b05", ATTR{idProduct}=="19b6", ATTR{power/autosuspend}="-1"

    '';
  };

  services.upower.criticalPowerAction = "Hibernate";

  services.xserver = {
    enable = true;

    # keymap
    xkb = {
      layout = "jp";
      variant = "";
    };

    # Enable the GNOME Desktop Environment.
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome = {
      enable = true;
      # Variable refresh rate (VRR)
      # TODO: there's still a manual step.  Figure out how to encode that here:
      #   "VRR can then be enabled for each supported monitor in the Display Settings under Refresh Rate"
      # https://wiki.archlinux.org/title/Variable_refresh_rate#Wayland_configuration
      # https://www.reddit.com/r/NixOS/comments/1ckpcji/comment/l2swmqz/
      # https://www.phoronix.com/news/GNOME-XWayland-Frac-Scaling
      # https://github.com/GNOME/mutter/blob/e3891781804dfda1896f9e286bc0f1a55ef39d63/data/org.gnome.mutter.gschema.xml.in#L117-L137
      extraGSettingsOverridePackages = [ pkgs.gnome.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['variable-refresh-rate', 'scale-monitor-framebuffer']
      '';
    };

    # videoDrivers = [ "amdgpu" "nvidia" "modeset" ];
  };
}
