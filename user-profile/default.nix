# https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
# https://discourse.nixos.org/t/declarative-package-management-for-normal-users/1823

# To install: nix-env -f . --set

{ pkgs ? import <nixpkgs> {}
, name ? "user-env"
}: with pkgs;
buildEnv {
  inherit name;
  extraOutputsToInstall = ["out" "bin" "lib"];
  paths = [
    curl
    discord
    element-desktop
    gitFull
    htop
    nix # If not on NixOS, this is important!
    firefox
    google-chrome
    icewm
    lutris
    pavucontrol
    protonup-qt
    redshift
    steam
    vim
    whatsapp-for-linux
    wineWowPackages.stable

    # TODO: package Line windows version like this:
    # https://github.com/emmanuelrosa/erosanix/blob/HEAD/pkgs/foobar2000.nix
    # https://discourse.nixos.org/t/using-wine-installing-foobar2000/17870/4
    # https://discourse.nixos.org/t/what-is-your-approach-to-packaging-wine-applications-with-nix-derivations/12799/3
    # https://nixos.wiki/wiki/Wine

    # Manifest to make sure imperative nix-env doesn't work (otherwise it will overwrite the profile, removing all packages other than the newly-installed one).
    (writeTextFile {
      name = "break-nix-env-manifest";
      destination = "/manifest.nix";
      text = ''
        throw ''\''
          Your user environment is a buildEnv which is incompatible with
          nix-env's built-in env builder. Edit your home expression and run
          update-profile instead!
        ''\''
      '';
    })
    # To allow easily seeing which nixpkgs version the profile was built from, place the version string in ~/.nix-profile/nixpkgs-version
    (writeTextFile {
      name = "nixpkgs-version";
      destination = "/nixpkgs-version";
      text = lib.version;
    })
  ];
}

