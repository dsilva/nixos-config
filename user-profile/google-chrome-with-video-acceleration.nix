# TODO: video acceleration with VA-API
#       https://chromium.googlesource.com/chromium/src/+/master/docs/gpu/vaapi.md
#       https://source.chromium.org/chromium/chromium/src/+/main:media/base/media_switches.cc;l=748-761;drc=a70b0c9730cb654b37ef4232a09647f2eb30fe90
#       https://www.reddit.com/r/linux/comments/17o4zg7/embarrassing_that_chrome_doesnt_have_video/
#       https://www.phoronix.com/news/Google-Chrome-Wayland-VA-API
#       https://discussion.fedoraproject.org/t/how-to-get-gpu-acceleration-working-in-chromium-browsers-for-amd-apus/75571/7
#       https://www.reddit.com/r/Fedora/comments/1cbnsbd/i_finally_managed_to_have_hardware_accelerated/
#       https://bbs.archlinux.org/viewtopic.php?pid=2177812#p2177812
#       https://www.reddit.com/r/linuxquestions/comments/1e7x1sq/comment/le37xz2/
#       https://wiki.archlinux.org/title/Chromium#Hardware_video_acceleration

# TODO: write a test to verify that chrome can play VP9 videos (which YouTube uses)
#       with hardware acceleration.
#       Run that test on every ./apply.sh to avoid regressions.
#       Run that test on every "nixos-rebuild switch" too.
#       https://github.com/puppeteer/puppeteer/issues/3637#issuecomment-1858625322
#       https://stackoverflow.com/questions/72902783/enabling-hardware-acceleration-for-headless-chromium-with-playwright

{ lib, google-chrome, vulkan-loader }:
let
  # As of 2024-08-02, by default Vulkan wakes up the nvidia gGPU:
  # https://forums.developer.nvidia.com/t/550-67-nvidia-vulkan-icd-wakes-up-dgpu-on-initialization-and-exit/288095/6
  # Either disable it, or force Vulkan to only see the AMD driver.
  use-vulkan = false;

  vulkan-environment = {
    # Select the Vulkan driver:
    #   https://github.com/KhronosGroup/Vulkan-Loader/blob/main/docs/LoaderDriverInterface.md#overriding-the-default-driver-discovery
    #
    # Use radeon_icd.x86_64.json (RADV) instead of amd_icd64.json (AMDVLK).
    # AMDVLK does not work with Wayland as of 2024-08-02:
    #   https://github.com/GPUOpen-Drivers/AMDVLK/issues/351#issuecomment-2198425641
    #   https://bbs.archlinux.org/viewtopic.php?id=294816
    #   https://www.reddit.com/r/kde/comments/18l3owr/comment/ke22onn/
    #   https://aur.archlinux.org/packages/zed-preview#comment-977807
    # Also, the mesa RADV driver is faster than AMD's own AMDVLK in general, though not always:
    #   https://www.reddit.com/r/linux_gaming/comments/16x40zv/why_does_amdvlk_exist_when_radv_is_superior/
    #   https://www.reddit.com/r/linux_gaming/comments/1aivi9o/linux_tech_tips_ep23_amdvlk_vs_radv_6_months_later/
    #   https://www.phoronix.com/review/amdvlk-radv-rt
    #
    # It's possible to choose the GPU with "MESA_VK_DEVICE_SELECT=1002:1900!"
    # and the driver with AMD_VULKAN_ICD=RADV
    #   https://wiki.archlinux.org/title/Vulkan#Switching
    # But that involves more indirection, more moving parts to debug when it doesn't work.
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
  };

  vulkan-features = [
    "Vulkan"
    "VulkanFromANGLE"
    "DefaultANGLEVulkan"
    "VaapiIgnoreDriverChecks"
    "PlatformHEVCDecoderSupport"
    "UseMultiPlaneFormatForHardwareVideo"
  ];

  no-vulkan-disable-features = [
    "Vulkan"
    # When disabling Vulkan, also disable Vulkan via ANGLE:
    #   https://groups.google.com/g/angleproject/c/kYAXkMMPF_E?pli=1
    "DefaultANGLEVulkan"
  ];

  gl-features = if use-vulkan then vulkan-features else [ ];

  enable-features = gl-features ++ [
    "TouchpadOverscrollHistoryNavigation"
    "VaapiVideoDecoder"
    "VaapiVideoEncoder"
  ];

  vulkan-disable-features = [ ];
  gl-disable-features = if use-vulkan then vulkan-disable-features else no-vulkan-disable-features;

  disable-features = gl-disable-features ++ [
    # "UseChromeOSDirectVideoDecoder"

    # Uncomment this if fonts are blurry in Wayland with fractional scaling
    # https://www.reddit.com/r/archlinux/comments/13gtogn/comment/jstqvlt/
    # "WaylandFractionalScaleV1"
  ];

  # gl=angle,angle=vulkan does not work in wayland yet:
  # https://issues.chromium.org/issues/334275637
  # But also in gnome, fonts are blurry with xwayland.
  use-wayland = true;

  # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
  # https://discourse.nixos.org/t/chromium-with-wayland-switches/15635
  wayland-args = [
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime"
  ];

  x11-args = [
    "--ozone-platform=x11"
  ];

  display-client-args = if use-wayland then wayland-args else x11-args;

  vulkan-args = [
    "--use-gl=angle"
    "--use-angle=vulkan"
  ];

  #"--use-gl=egl"
  gl-args = if use-vulkan then vulkan-args else [ ];

  commandLineArgs = display-client-args ++ gl-args ++ [
    "--enable-accelerated-video-decode"
    "--disable-features=${lib.concatStringsSep "," disable-features}"
    "--enable-features=${lib.concatStringsSep "," enable-features}"
  ];

  overrides = { inherit commandLineArgs; };

  set-environment-args =
    lib.attrsets.mapAttrsToList (name: value: ''--set ${name} ${value}'') vulkan-environment;

  attrs = {
    # Use amd gpu for vulkan:
    #   https://www.reddit.com/r/NixOS/comments/17i7zeb/comment/k6t1zk4/
    # Also work around Chrome failing to find libvulkan with:
    #   Failed to load 'libvulkan.so.1': libvulkan.so.1: cannot open shared object file: No such file or directory
    #   Failed to create and initialize Vulkan implementation.
    # https://github.com/NixOS/nixpkgs/issues/150398#issuecomment-1036323888
    # https://discourse.nixos.org/t/modify-chromium-command-provide-path-to-dynamic-library/19906
    # But it seems like that shouldn't be an issue since NixOS 22.05:
    # https://github.com/NixOS/nixpkgs/commit/007af34263d102667f077363b3958e6bf4b05ea8
    # Maybe do this instead of changing LD_LIBRARY_PATH:
    #   https://www.reddit.com/r/NixOS/comments/17i7zeb/comment/kpjmmqu/
    postInstall = ''
      wrapProgram $out/bin/google-chrome-stable \
      ${lib.concatStringsSep " " set-environment-args} \
        --prefix LD_LIBRARY_PATH : ${vulkan-loader.out}/lib/
    '';
  };

in

(google-chrome.override overrides).overrideAttrs (finalAttrs: previousAttrs: attrs)
