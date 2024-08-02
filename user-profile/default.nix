# https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
# https://discourse.nixos.org/t/declarative-package-management-for-normal-users/1823

# To apply changes: ./apply.sh

{ pkgs }:
with pkgs;
buildEnv {
  name = "user-env";
  extraOutputsToInstall = [ "out" "bin" "lib" ];
  paths = [
    alacritty
    curl
    discord
    element-desktop
    gitFull
    gnome.gnome-terminal
    htop
    nil
    nix # If not on NixOS, this is important!
    nixd
    nixpkgs-fmt
    firefox
    google-chrome
    icewm
    lutris
    # Without a keyring package, vscode will sync extensions with “weaker encryption”
    # https://discourse.nixos.org/t/vscode-not-opening-github-sign-in-to-activate-syncing/40715
    pass
    pavucontrol
    protonup-qt
    redshift
    screen
    steam
    tmux
    (vscode.fhsWithPackages (ps: with ps; [ rustup zlib openssl.dev pkg-config ]))
    vim
    whatsapp-for-linux
    wineWowPackages.stable
    # Required for vscode links and synching
    # https://discourse.nixos.org/t/vscode-not-opening-github-sign-in-to-activate-syncing/40715
    xdg-utils

    # TODO: package Line windows version like this:
    # https://github.com/emmanuelrosa/erosanix/blob/HEAD/pkgs/foobar2000.nix
    # https://discourse.nixos.org/t/using-wine-installing-foobar2000/17870/4
    # https://discourse.nixos.org/t/what-is-your-approach-to-packaging-wine-applications-with-nix-derivations/12799/3
    # https://nixos.wiki/wiki/Wine

    # Manifest to make sure imperative nix-env doesn't work (otherwise it will overwrite the profile, removing all packages other than the newly-installed one).
    # (writeTextFile {
    #   name = "break-nix-env-manifest";
    #   destination = "/manifest.nix";
    #   text = ''
    #     throw ''\''
    #     Your
    #     user
    #     environment
    #     is
    #     a
    #     buildEnv
    #     which
    #     is
    #     incompatible with
    #   nix-env's built-in env builder. Edit your home expression and run
    #   update-profile instead!
    #   ''\''
    #   '';
    # })
    # To allow easily seeing which nixpkgs version the profile was built from, place the version string in ~/.nix-profile/nixpkgs-version
    (writeTextFile {
      name = "nixpkgs-version";
      destination = "/nixpkgs-version";
      text = lib.version;
    })
  ];
}
