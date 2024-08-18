{ config, inputs, pkgs, pkgs-unstable, ... }:

{
  # https://discourse.nixos.org/t/what-is-the-difference-between-systemd-services-and-systemd-user-services/25222
  # https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=systemd.user.services.%3Cname%3E
  systemd.user.services = {
    # Handle touchpad gestures like three-finger-drag with Fusuma.
    # Alternatively, https://github.com/marsqing/libinput-three-finger-drag might also work.
    # https://github.com/iberianpig/fusuma/issues/173#issuecomment-2058984377
    # https://www.reddit.com/r/NixOS/comments/11m5yeh/comment/l47uz1s/
    # https://discourse.nixos.org/t/fusuma-not-working/21416/8
    # https://github.com/nix-community/home-manager/blob/master/modules/services/fusuma.nix
    fusuma = {
      description = "Fusuma handles touchpad gestures";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      restartIfChanged = false;

      environment = {
        # https://github.com/NixOS/nixpkgs/blob/bda6ce0df9f508d326d71b16b398c6878908a79a/nixos/modules/programs/ydotool.nix#L87C7-L87C21
        # Defaults to /run/user/1000/.ydotool_socket
        # It's unclear why the environment variable doesn't propagate to this systemd user service,
        # because it does propagate to user shells.
        YDOTOOL_SOCKET = "/run/ydotoold/socket";
      };

      serviceConfig = {
        Restart = "on-failure";
        ExecStart = "${pkgs.fusuma}/bin/fusuma -c ${./fusuma.yaml}";
      };
    };

  };
}
