{ inputs, pkgs, ... }:
{

  programs.scroll = {
    enable = true;
    package = inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-stable;

    extraSessionCommands = ''
      # Tell QT, GDK and others to use the Wayland backend by default, X11 if not available
      export QT_QPA_PLATFORM="wayland;xcb"
      export GDK_BACKEND="wayland,x11"
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland

      # XDG desktop variables to set scroll as the desktop
      export XDG_CURRENT_DESKTOP=scroll
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=scroll

      # Configure Electron to use Wayland instead of X11
      export ELECTRON_OZONE_PLATFORM_HINT=wayland
    '';
  };

  # nautilus deps
  services.gvfs.enable = true;
  services.gnome.glib-networking.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gnome.at-spi2-core.enable = true;
  services.gnome.localsearch.enable = true;
  services.gnome.tinysparql.enable = true;

  environment.systemPackages = with pkgs; [
    gcc
    cacert
    openssl
    wget
    curl
    tree
    mesa
    socat
    gawk
    nmap
    psmisc
    fd
    fzf
    jq
    hjson-go
    yq-go
    slop
    httpie
    cachix
    rclone
    trash-cli
    devenv
    libqalculate  # for qalc
    qalculate-qt
    unzipNLS
    zip
    p7zip
    unar
    loupe
    yad
    nwg-look
    mpv-unwrapped
    man
    coreutils
    xdg-utils
    gnused
    findutils
    ripgrep
    htop
    fastfetch
    inxi
    hwinfo
    wlr-randr
    ddcutil
    wlsunset
    brightnessctl
    libgtop
    dart-sass
    swww # wallpaper
    wl-clipboard
    cliphist
    libnotify # For notify-send
    mako
    slurp
    grim
    ksnip
    material-symbols
    matugen
    jellyfin-ffmpeg
    nautilus
    alacritty-graphics
    eza
    tealdeer
    pciutils
    android-tools
  ];

  programs.nix-ld.enable = true;

  programs.vim = {
    enable = true;
  };

  services.flatpak.enable = true;

  services.upower = {
    enable = true;
    ignoreLid = true;
  };

  services.libinput.enable = true;
  programs.mtr.enable = true;
  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  services.dbus.enable = true;

  services.udisks2.enable = true;

  programs.dconf.enable = true;

  programs.appimage.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        kpenter = "enter";
      };
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    IdleAction = "ignore";
    IdleActionSec = 0;
  };
  boot.kernelParams = [ "consoleblank=0" "button.lid_init_state=open" ];

  programs.bash = {
    enable = true;
    completion.enable = true;
  };

}
