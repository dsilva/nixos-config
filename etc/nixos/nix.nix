{ config, inputs, pkgs, pkgs-unstable, ... }:
let
  overlay = final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/316538#issuecomment-2143736105
    asusctl = pkgs-unstable.asusctl;
    supergfxctl = pkgs-unstable.supergfxctl;

   # linuxPackages-unstable = pkgs-unstable.linuxPackages_latest;

    gnome = prev.gnome // {
      gnome-shell = prev.gnome.gnome-shell.overrideAttrs (finalAttrs: prevAttrs: {
        # gnome reserves 3-finger gestures for itself, which doesn't let us set up 3-finger drag.
        # Change gnome's gestures to use 4 fingers.
        # https://gitlab.gnome.org/GNOME/gnome-shell/-/blob/46.4/js/ui/swipeTracker.js?ref_type=tags
        # https://github.com/iberianpig/fusuma/issues/173#issuecomment-2095292326
        postPatch = ''
          ${prevAttrs.postPatch}
          
          substituteInPlace js/ui/swipeTracker.js \
            --replace-fail "const GESTURE_FINGER_COUNT = 3;" "const GESTURE_FINGER_COUNT = 4;"
        '';
      });
    };
  };

in

{
  # https://discourse.nixos.org/t/no-space-left-on-boot/24019/21
  nix.gc.automatic = true;
  nix.gc.randomizedDelaySec = "14m";
  nix.gc.options = "--delete-older-than 10d";

  # Is this already the default as of NixOS 24.05?
  # nix.nixPath = [ "nixpkgs=flake:nixpkgs" "/nix/var/nix/profiles/per-user/root/channels" ];

  # Is this already the default as of NixOS 24.05?
  # nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nixpkgs.config.allowUnfree = true;

  # NixOS service definitions reference packages from nixpkgs.
  # Sometimes they let you override packages, but not always.
  # To use a different version of a package and make sure that
  # services pick up that version, add it to nixpkgs overlays.
  #
  # https://www.reddit.com/r/NixOS/comments/1cgiywn/comment/l1yf3d6/
  # https://discordapp.com/channels/725125934759411753/770379483353055264/1226274730353496108
  nixpkgs.overlays = [ overlay ];


  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];

    # https://determinate.systems/posts/changelog-determinate-nix-352/
    # https://www.reddit.com/r/NixOS/comments/1l01y5g/comment/mvali7h/
    #lazy-trees = true;

    substituters = [
      "https://cosmic.cachix.org/"
      "https://install.determinate.systems"
    ];
    trusted-public-keys = [
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };
}
