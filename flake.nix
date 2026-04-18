{
  description = "NixOS configuration for noname";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    scroll-flake = {
      url = "github:AsahiRocks/scroll-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    stylix,
    nix-index-database,
    scroll-flake,
    nixvim,
    ...
  } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ({ config, lib, modulesPath, pkgs, ... }:
          {
            imports = [
              (modulesPath + "/installer/scan/not-detected.nix")
              stylix.nixosModules.stylix
              home-manager.nixosModules.home-manager
              nix-index-database.nixosModules.default
              scroll-flake.nixosModules.default
              ./secret.nix
            ];

            boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
            boot.initrd.kernelModules = [ ];
            boot.initrd.systemd.enable = true;
            boot.initrd.systemd.services.machine-id-init = {
              description = "Initialize machine-id in initrd";
              wantedBy = [ "initrd.target" ];
              after = [ "systemd-journald.service" ];
              unitConfig = {
                DefaultDependencies = false;
                ConditionPathExists = "!/run/machine-id";
              };
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.systemd}/bin/systemd-id128 new";
                StandardOutput = "file:/run/machine-id";
              };
            };
            boot.kernelModules = [ "kvm-intel" "tcp_bbr" ];
            boot.extraModulePackages = [ ];
            boot.kernelParams = [ "fbcon=rotate:1" "consoleblank=0" "button.lid_init_state=open" ];
            boot.blacklistedKernelModules = [ "intel_ish_ipc" ];
            boot.kernelPackages = pkgs.linuxPackages_latest;
            boot.loader.systemd-boot.enable = true;
            boot.loader.efi.canTouchEfiVariables = true;
            boot.kernel.sysctl = {
              "net.core.default_qdisc" = "fq";
              "net.ipv4.tcp_congestion_control" = "bbr";
            };

            fileSystems."/" = {
              device = "/dev/disk/by-label/NIXROOT";
              fsType = "ext4";
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-label/NIXBOOT";
              fsType = "vfat";
              options = [ "fmask=0022" "dmask=0022" ];
            };

            swapDevices = [ ];
            zramSwap.enable = true;

            networking.useDHCP = lib.mkDefault true;
            networking = {
              hostName = "";
              enableIPv6 = false;
              nameservers = [ "240.0.0.1" ];
              networkmanager = {
                enable = true;
                dhcp = "internal";
                dns = "none";
                wifi.macAddress = "preserve";
                ethernet.macAddress = "preserve";
                wifi.scanRandMacAddress = true;
                settings = {
                  main = {
                    "hostname-mode" = "none";
                    "dhcp-send-hostname" = false;
                  };
                  connection = {
                    "ipv4.dhcp-client-id" = "mac";
                    "ipv6.dhcp-duid" = "ll";
                  };
                };
              };
            };

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            nixpkgs.config = {
              allowUnfree = true;
              allowUnfreePredicate = (_: true);
              allowAliases = true;
            };
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
            hardware.graphics = {
              enable = true;
              enable32Bit = true;
              extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver ];
              extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ];
            };
            hardware.i2c.enable = true;
            hardware.bluetooth = {
              enable = true;
              powerOnBoot = true;
              settings = {
                General = {
                  ControllerMode = "bredr";
                  FastConnectable = true;
                  Experimental = "true";
                };
              };
            };

            time.timeZone = "Asia/Shanghai";

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

            system.extraDependencies =
              let
                collectFlakeInputs = input:
                  [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));
              in
              builtins.concatMap collectFlakeInputs (builtins.attrValues inputs)
              ++ [ pkgs.stdenvNoCC ];

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
              jq
              hjson-go
              yq-go
              slop
              httpie
              cachix
              rclone
              trash-cli
              devenv
              libqalculate
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
              swaybg
              wl-clipboard
              cliphist
              libnotify
              mako
              slurp
              grim
              drawing
              material-symbols
              matugen
              jellyfin-ffmpeg
              nautilus
              alacritty-graphics
              eza
              tealdeer
              pciutils
              android-tools
              lsof
              whois
              file
              pamixer
              wiremix
              playerctl
              wireplumber
              bluez
              bluez-tools
              bluetui
              ctop
              minikube
              kubectl
              kubernetes-helm
              wirelesstools
              networkmanager
              networkmanagerapplet
              dnsutils
              macchanger
              sysstat
              nethogs
              busybox
              (python313.withPackages (python-pkgs:
                with python-pkgs; [
                  requests
                  numpy
                  pandas
                  pillow
                  prompt-toolkit
                  pyperclip
                  moviepy
                  uvicorn
                  fastapi
                  websockets
                  faker
                ]))
              uv
            ];
            environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
            environment.etc."machine-id".source = "/run/machine-id";
            environment.variables = {
              EDITOR = "nvim";
            };
            environment.sessionVariables = {
              INPUT_METHOD = "fcitx";
              GTK_IM_MODULE = "fcitx";
              QT_IM_MODULE = "fcitx";
              SDL_IM_MODULE = "fcitx";
              XMODIFIERS = "@im=fcitx";
              HISTSIZE = 1000;
              HISTFILESIZE = 2000;
              HISTCONTROL = "ignoreboth:erasedups";
              NIXPKGS_ALLOW_UNFREE = 1;
              _ZO_MAXAGE = 25000;
              PATH = lib.mkAfter [ "${config.users.users.noname.home}/.npm-global/bin" "${config.users.users.noname.home}/.bun/bin" ];
              ELECTRON_OVERRIDE_DIST_PATH = "${pkgs.electron}/bin";
              _ZO_DOCTOR = 0;
            };

            programs.scroll = {
              enable = true;
              package = inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-stable;
              extraSessionCommands = ''
                export QT_QPA_PLATFORM="wayland;xcb"
                export GDK_BACKEND="wayland,x11"
                export SDL_VIDEODRIVER=wayland
                export CLUTTER_BACKEND=wayland

                export XDG_CURRENT_DESKTOP=scroll
                export XDG_SESSION_TYPE=wayland
                export XDG_SESSION_DESKTOP=scroll

                export ELECTRON_OZONE_PLATFORM_HINT=wayland
              '';
            };
            programs.nix-ld.enable = true;
            programs.vim.enable = true;
            programs.mtr.enable = true;
            programs.dconf.enable = true;
            programs.appimage.enable = true;
            programs.bash = {
              enable = true;
              completion.enable = true;
            };
            programs.steam.enable = true;
            programs.nix-index-database.comma.enable = true;

            security.rtkit.enable = true;
            security.pam.loginLimits = [
              { domain = "*"; item = "nofile"; type = "soft"; value = "4096"; }
              { domain = "*"; item = "nofile"; type = "hard"; value = "4096"; }
            ];

            users.users.noname = {
              hashedPassword = "$6$/zQWdKvVPRuXb1SP$OdrUjAcR8Vm.LP0YOLTEKAEg0q4xrgnZL0ySkpyLpMkzoRY8GQZwRPBStjNhTg3T9CZjHp91A6gmwY82NKO3f/";
              isNormalUser = true;
              description = "n0n4w3";
              extraGroups = [
                "networkmanager"
                "wheel"
                "power"
                "docker"
                "adbusers"
                "i2c"
              ];
              shell = pkgs.bash;
            };

            services.pulseaudio.enable = false;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
              jack.enable = true;
              wireplumber.enable = true;
            };
            services.blueman.enable = true;
            services.displayManager = {
              defaultSession = "Scroll";
              ly = {
                enable = true;
                settings = {
                  clock = "%H:%M:%S";
                  bigclock = "en";
                  animation = "colormix";
                };
              };
            };
            services.gvfs.enable = true;
            services.gnome.glib-networking.enable = true;
            services.gnome.gnome-keyring.enable = true;
            services.gnome.at-spi2-core.enable = true;
            services.gnome.localsearch.enable = true;
            services.gnome.tinysparql.enable = true;
            services.flatpak.enable = true;
            services.upower = {
              enable = true;
              ignoreLid = true;
            };
            services.libinput.enable = true;
            services.dbus.enable = true;
            services.udisks2.enable = true;
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
            services.avahi.enable = false;
            services.mihomo = {
              enable = true;
              tunMode = true;
              webui = pkgs.metacubexd;
              configFile = pkgs.writeText "mihomo.yaml" ''
                mode: rule
                mixed-port: 7897
                allow-lan: false
                log-level: info
                ipv6: false
                external-controller: 127.0.0.1:9090
                secret: ""
                unified-delay: true
                external-controller-unix: /run/user/1000/clash-verge-rev/verge-mihomo.sock
                geox-url:
                  geoip: "https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"
                  geosite: "https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
                  mmdb: "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/GeoLite2-Country.mmdb"
                  asn: "https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/GeoLite2-ASN.mmdb"
                profile:
                  tracing: true
                  store-selected: true
                experimental:
                  sniff-tls-sni: true
                tun:
                  auto-detect-interface: true
                  auto-route: true
                  device: Mihomo
                  dns-hijack:
                  - any:53
                  - tcp://any:53
                  mtu: 1500
                  stack: gvisor
                  strict-route: false
                  enable: true
                dns:
                  use-hosts: true
                  use-system-hosts: true
                  hosts:
                    'dns.google': [ 8.8.8.8, 8.8.4.4 ]
                    'cloudflare-dns.com': [ 1.1.1.1, 1.0.0.1 ]
                    'dns.quad9.net': [ 9.9.9.9, 149.112.112.112 ]
                    'doh.opendns.com': [ 208.67.222.222, 208.67.220.220 ]
                    'dns.adguard-dns.com': [ 94.140.14.14, 94.140.15.15 ]
                    'doh.pub': [ 119.29.29.29, 120.53.53.53 ]
                    'dns.alidns.com': [ 223.5.5.5, 223.6.6.6 ]
                  default-nameserver:
                  - tls://8.8.8.8
                  - tls://1.1.1.1
                  nameserver:
                  - https://dns.google/dns-query
                  - https://cloudflare-dns.com/dns-query
                  fallback:
                  - https://dns.quad9.net/dns-query
                  - https://doh.opendns.com/dns-query
                  - https://dns.adguard-dns.com/dns-query
                  fallback-filter:
                    ipcidr:
                    - 240.0.0.0/4
                    - 0.0.0.0/32
                  direct-nameserver:
                  - https://doh.pub/dns-query
                  - https://dns.alidns.com/dns-query
                  direct-nameserver-follow-policy: false
                  proxy-server-nameserver:
                  - https://doh.pub/dns-query
                  - https://dns.alidns.com/dns-query
                  enable: true
                  enhanced-mode: fake-ip
                  fake-ip-filter:
                  - '*.lan'
                  - '*.local'
                  - '*.arpa'
                  - time.*.com
                  - ntp.*.com
                  - time.*.com
                  - +.market.xiaomi.com
                  - localhost.ptlogin2.qq.com
                  - '*.msftncsi.com'
                  - www.msftconnecttest.com
                  fake-ip-filter-mode: blacklist
                  fake-ip-range: 198.18.0.1/16
                  ipv6: false
                  listen: 127.0.0.1:53
                  prefer-h3: false
                  respect-rules: false
                external-controller-cors:
                  allow-private-network: true
                  allow-origins:
                  - '*'
                clash-for-android:
                  append-system-dns: false
                proxy-providers:
                  sub2:
                    type: file
                    path: /var/lib/private/mihomo/providers/sub2.yaml
                    health-check:
                      enable: false
                      interval: 1200
                      url: https://www.apple.com/library/test/success.html
                  sub3:
                    type: file
                    path: /var/lib/private/mihomo/providers/sub3.yaml
                    health-check:
                      enable: false
                      interval: 1200
                      url: https://www.apple.com/library/test/success.html
                proxy-groups:
                  - name: SELECT
                    type: select
                    use:
                      - sub2
                      - sub3
                    proxies:
                      - ANYTLS
                      - VLESS
                      - DIRECT
                  - name: ANYTLS
                    type: url-test
                    url: https://www.apple.com/library/test/success.html
                    interval: 1200
                    lazy: true
                    use:
                      - sub2
                    exclude-filter: "香港|HongKong"
                  - name: VLESS
                    type: url-test
                    url: https://www.apple.com/library/test/success.html
                    interval: 1200
                    lazy: true
                    use:
                      - sub3
                    exclude-filter: "香港|HongKong"
                rules:
                  - GEOSITE,category-ads-all,REJECT

                  - DOMAIN,www.apple.com,SELECT
                  - DOMAIN,browserleaks.com,SELECT
                  - IP-CIDR,47.110.248.69/8,DIRECT,no-resolve
                  - IP-CIDR,101.37.64.91/8,DIRECT,no-resolve
                  - IP-CIDR,101.37.156.175/8,DIRECT,no-resolve

                  - GEOSITE,cn,DIRECT
                  - GEOSITE,private,DIRECT
                  - GEOSITE,steam@cn,DIRECT
                  - GEOSITE,category-games@cn,DIRECT

                  - DOMAIN,copypaste.me,DIRECT
                  - DOMAIN,mirrors.tuna.tsinghua.edu.cn,DIRECT
                  - DOMAIN-SUFFIX,feishu.cn,DIRECT
                  - DOMAIN-SUFFIX,feishucdn.com,DIRECT
                  - DOMAIN,dns.alidns.com,DIRECT
                  - DOMAIN,doh.pub,DIRECT

                  - GEOSITE,geolocation-!cn,SELECT
                  - GEOSITE,google,SELECT
                  - GEOSITE,youtube,SELECT
                  - GEOSITE,telegram,SELECT
                  - GEOSITE,netflix,SELECT
                  - GEOSITE,github,SELECT

                  - GEOIP,private,DIRECT,no-resolve
                  - GEOIP,telegram,SELECT
                  - GEOIP,cn,DIRECT

                  - MATCH,SELECT
              '';
            };

            systemd.services.systemd-machine-id-commit.enable = false;
            systemd.services.spoof-identity = {
              description = "Spoof Hostname, DMI Hardware Info and MAC Addresses";
              wantedBy = [ "multi-user.target" ];
              before = [ "NetworkManager.service" "network-pre.target" ];
              after = [ "local-fs.target" ];
              serviceConfig = {
                Type = "oneshot";
                User = "root";
                RemainAfterExit = true;
              };
              path = with pkgs; [ iproute2 macchanger inetutils util-linux bash ];
              script = ''
                #!/usr/bin/env bash

                rand_hex() {
                    head -c "$1" /dev/urandom | od -An -tx1 | tr -d ' \n'
                }

                spoof_file() {
                    local name="$1"
                    local content="$2"
                    local target="/sys/class/dmi/id/$name"
                    local fake="/run/dmi_spoof_$name"

                    if [ -f "$target" ]; then
                        echo "$content" > "$fake"
                        umount "$target" 2>/dev/null || true
                        mount --bind "$fake" "$target"
                    fi
                }

                PROFILE=$(( RANDOM % 26 ))

                case $PROFILE in
                    0)
                        NEW_HOSTNAME="thinkpad-$(rand_hex 2)"
                        VENDOR="LENOVO"
                        MODEL="20XW002JUS"
                        VERSION="ThinkPad X1 Carbon Gen 9"
                        ;;
                    1)
                        NEW_HOSTNAME="xps-$(rand_hex 2)"
                        VENDOR="Dell Inc."
                        MODEL="XPS 13 9310"
                        VERSION="1.4.0"
                        ;;
                    2)
                        NEW_HOSTNAME="framework-$(rand_hex 2)"
                        VENDOR="Framework"
                        MODEL="Laptop (13th Gen Intel Core)"
                        VERSION="A4"
                        ;;
                    3)
                        NEW_HOSTNAME="desktop-$(rand_hex 2)"
                        VENDOR="ASUSTeK COMPUTER INC."
                        MODEL="TUF GAMING B550M-PLUS"
                        VERSION="Rev X.0x"
                        ;;
                    4)
                        NEW_HOSTNAME="pop-os-$(rand_hex 2)"
                        VENDOR="System76"
                        MODEL="Lemur Pro"
                        VERSION="lemp10"
                        ;;
                    5)
                        NEW_HOSTNAME="rog-$(rand_hex 2)"
                        VENDOR="ASUSTeK COMPUTER INC."
                        MODEL="GA401IV"
                        VERSION="1.0"
                        ;;
                    6)
                        NEW_HOSTNAME="hp-elitebook-$(rand_hex 2)"
                        VENDOR="HP"
                        MODEL="HP EliteBook 840 G8 Notebook PC"
                        VERSION="SBKPF1.23"
                        ;;
                    7)
                        NEW_HOSTNAME="nuc-server-$(rand_hex 2)"
                        VENDOR="Intel Corporation"
                        MODEL="NUC11PAHi7"
                        VERSION="M90a"
                        ;;
                    8)
                        NEW_HOSTNAME="ideapad-$(rand_hex 2)"
                        VENDOR="LENOVO"
                        MODEL="82L7"
                        VERSION="Xiaoxin Pro 14 IAP 2022"
                        ;;
                    9)
                        NEW_HOSTNAME="legion-$(rand_hex 2)"
                        VENDOR="LENOVO"
                        MODEL="82WK"
                        VERSION="Legion Y9000P IAH7H"
                        ;;
                    10)
                        NEW_HOSTNAME="matebook-$(rand_hex 2)"
                        VENDOR="HUAWEI"
                        MODEL="MRGFG-XX"
                        VERSION="M1030"
                        ;;
                    11)
                        NEW_HOSTNAME="huawei-$(rand_hex 2)"
                        VENDOR="HUAWEI"
                        MODEL="HKF-XX"
                        VERSION="M1020"
                        ;;
                    12)
                        NEW_HOSTNAME="mi-notebook-$(rand_hex 2)"
                        VENDOR="TIMI"
                        MODEL="TM2113"
                        VERSION="Xiaomi Notebook Pro 15 2022"
                        ;;
                    13)
                        NEW_HOSTNAME="redmibook-$(rand_hex 2)"
                        VENDOR="TIMI"
                        MODEL="TM2019"
                        VERSION="RedmiBook Pro 14"
                        ;;
                    14)
                        NEW_HOSTNAME="magicbook-$(rand_hex 2)"
                        VENDOR="HONOR"
                        MODEL="GLO-G56"
                        VERSION="MagicBook 14 2022"
                        ;;
                    15)
                        NEW_HOSTNAME="hasee-$(rand_hex 2)"
                        VENDOR="Hasee Computer"
                        MODEL="Z8-DA5NP"
                        VERSION="Standard"
                        ;;
                    16)
                        NEW_HOSTNAME="mechrevo-$(rand_hex 2)"
                        VENDOR="MECHREVO"
                        MODEL="JL16K"
                        VERSION="V1.0"
                        ;;
                    17)
                        NEW_HOSTNAME="colorful-$(rand_hex 2)"
                        VENDOR="Colorful Technology"
                        MODEL="X15 AT 23"
                        VERSION="V1.0"
                        ;;
                    18)
                        NEW_HOSTNAME="hp-zhan-$(rand_hex 2)"
                        VENDOR="HP"
                        MODEL="HP ProBook 440 G9"
                        VERSION="KBC Version 53.27.00"
                        ;;
                    19)
                        NEW_HOSTNAME="omen-$(rand_hex 2)"
                        VENDOR="HP"
                        MODEL="OMEN by HP Laptop 16-b1xxx"
                        VERSION="98.33"
                        ;;
                    20)
                        NEW_HOSTNAME="dell-g15-$(rand_hex 2)"
                        VENDOR="Dell Inc."
                        MODEL="Dell G15 5520"
                        VERSION="1.10.0"
                        ;;
                    21)
                        NEW_HOSTNAME="msi-katana-$(rand_hex 2)"
                        VENDOR="Micro-Star International Co., Ltd."
                        MODEL="Katana GF66 12UE"
                        VERSION="REV:1.0"
                        ;;
                    22)
                        NEW_HOSTNAME="asus-tianxuan-$(rand_hex 2)"
                        VENDOR="ASUSTeK COMPUTER INC."
                        MODEL="FA507UV"
                        VERSION="1.0"
                        ;;
                    23)
                        NEW_HOSTNAME="thinkbook-$(rand_hex 2)"
                        VENDOR="LENOVO"
                        MODEL="21J2"
                        VERSION="ThinkBook 14+ IAP"
                        ;;
                    24)
                        NEW_HOSTNAME="yoga-$(rand_hex 2)"
                        VENDOR="LENOVO"
                        MODEL="82QE"
                        VERSION="Yoga Pro 14s IAH7"
                        ;;
                    25)
                        NEW_HOSTNAME="acer-swift-$(rand_hex 2)"
                        VENDOR="Acer"
                        MODEL="Swift SF314-512"
                        VERSION="V1.12"
                        ;;
                esac

                SERIAL="$(rand_hex 8 | tr 'a-f' 'A-F')"
                UUID="$(cat /proc/sys/kernel/random/uuid)"

                echo "Spoofing Identity: Profile=$PROFILE, Host=$NEW_HOSTNAME, Vendor=$VENDOR"

                safe_vendor="''${VENDOR// /}"
                safe_model="''${MODEL// /}"
                safe_version="''${VERSION// /}"
                safe_serial="''${SERIAL// /}"

                BIOS_DATE="05/20/2023"
                BIOS_VER="2.5.1"

                if [[ "$PROFILE" == "3" || "$PROFILE" == "7" ]]; then
                    CHASSIS_TYPE="3"
                else
                    CHASSIS_TYPE="10"
                fi

                NEW_MODALIAS="dmi:bvn''${safe_vendor}:bvr''${BIOS_VER}:bd''${BIOS_DATE}:br''${BIOS_VER}:svn''${safe_vendor}:pn''${safe_model}:pvr''${safe_version}:rvn''${safe_vendor}:rn''${safe_model}:rvr''${safe_version}:cvn''${safe_vendor}:ct''${CHASSIS_TYPE}:cvr''${safe_version}:sku''${safe_serial}:"

                hostname "$NEW_HOSTNAME"

                spoof_file "sys_vendor"      "$VENDOR"
                spoof_file "board_vendor"    "$VENDOR"
                spoof_file "chassis_vendor"  "$VENDOR"
                spoof_file "product_name"    "$MODEL"
                spoof_file "board_name"      "$MODEL"
                spoof_file "product_version" "$VERSION"
                spoof_file "product_serial"  "$SERIAL"
                spoof_file "board_serial"    "$SERIAL"
                spoof_file "chassis_serial"  "$SERIAL"
                spoof_file "product_uuid"    "$UUID"
                spoof_file "modalias"        "$NEW_MODALIAS"

                echo "Spoofing MAC addresses..."

                for iface_path in /sys/class/net/*; do
                    iface_name="''${iface_path##*/}"

                    if [[ "$iface_name" == "lo" || "$iface_name" == "docker0" || "$iface_name" == "Mihomo" ]]; then
                        continue
                    fi

                    if [[ ! -e "/sys/class/net/$iface_name/device" ]]; then
                        echo "  -> Skipping $iface_name (no backing device, likely virtual or transient)"
                        continue
                    fi

                    echo "  -> Randomizing MAC for interface: $iface_name"

                    ip link set dev "$iface_name" down

                    macchanger -r "$iface_name"
                done
              '';
            };
            systemd.services.mihomo-sub = {
              description = "Update Mihomo subscription files";
              wantedBy = [ "multi-user.target" ];
              path = with pkgs; [ bash curl coreutils util-linux ];
              serviceConfig = {
                Type = "simple";
                User = "root";
              };
              script = ''
                #!/usr/bin/env bash
                set -euo pipefail

                SUBS="$SUBSCRIPTION"

                CURL_GLOBAL_OPTS=(
                  -L
                  -H "User-Agent: mihomo/1.19.17"
                  --retry 3
                  --connect-timeout 10
                )

                MIN_INTERVAL_SEC=7200
                LOOP_SLEEP_SEC=600
                INITIAL_DELAY_SEC=600
                LOCK_FILE="/var/lib/private/mihomo/providers/mihomo-sub.lock"

                stamp_path() { printf "%s.stamp" "$1"; }

                last_success() {
                  local sfile
                  sfile=$(stamp_path "$1")
                  [[ -f $sfile ]] && cat "$sfile" || return 1
                }

                mark_success() {
                  local sfile
                  sfile=$(stamp_path "$1")
                  printf "%s\n" "$(date +%s)" > "$sfile"
                }

                should_update() {
                  local out="$1" last now
                  if ! last=$(last_success "$out" 2>/dev/null); then
                    return 0
                  fi
                  now=$(date +%s)
                  (( now - last >= MIN_INTERVAL_SEC )) && return 0 || return 1
                }

                fetch_one() {
                  local url="$1" out="$2" tmp
                  echo "[$(date -Is)] Fetch   $url -> $out"
                  tmp=$(mktemp)
                  if curl "''${CURL_GLOBAL_OPTS[@]}" "$url" -o "$tmp"; then
                    if [[ -s "$tmp" ]]; then
                      mkdir -p "$(dirname "$out")"
                      mv "$tmp" "$out"
                      mark_success "$out"
                      echo "[$(date -Is)] Saved   $out   (stamp updated)"
                    else
                      echo "[$(date -Is)] ERROR   $url returned empty file, keeping old one" >&2
                      rm -f "$tmp"
                    fi
                  else
                    echo "[$(date -Is)] ERROR   curl failed ($url)" >&2
                    rm -f "$tmp"
                  fi
                }

                process_all() {
                  echo "$SUBS" | tr ';' '\n' | while read -r url out || [[ -n $url ]]; do
                    [[ -z $url || $url =~ ^# ]] && continue
                    if should_update "$out"; then
                      fetch_one "$url" "$out"
                    else
                      echo "[`date -Is`] Skip    $out fresh"
                    fi
                  done
                }

                LOCK_DIR=$(dirname "$LOCK_FILE")
                mkdir -p "$LOCK_DIR"
                chown -R nobody:nogroup /var/lib/private/mihomo

                exec 200>"$LOCK_FILE"
                flock -n 200 || { echo "[`date -Is`] Another instance running, exit"; exit 0; }

                echo "[`date -Is`] Mihomo-sub started; first run after ''${INITIAL_DELAY_SEC}s"
                trap 'echo "[`date -Is`] SIGTERM caught, exit"; exit 0' TERM INT

                sleep "$INITIAL_DELAY_SEC"

                while :; do
                  process_all
                  chown -R nobody:nogroup /var/lib/private/mihomo
                  sleep "$LOOP_SLEEP_SEC" &
                  wait $!
                done
              '';
            };

            services.qemuGuest.enable = false;
            services.xserver.videoDrivers = [ ];

            virtualisation.docker.enable = true;

            xdg.portal = {
              enable = true;
              wlr.enable = true;
              extraPortals = with pkgs; [
                xdg-desktop-portal
                xdg-desktop-portal-wlr
                xdg-desktop-portal-gtk
              ];
            };

            nix.gc = {
              automatic = true;
              dates = "daily";
              options = "--delete-older-than 10d";
            };

            nix.settings = {
              keep-derivations = true;
              keep-outputs = true;
              trusted-users = [ "root" "noname" ];
              experimental-features = [ "nix-command" "flakes" ];
              substituters = [
                "https://cache.nixos.org"
              ];
              trusted-substituters = [
                "https://cache.nixos.org"
              ];
              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ];
            };

            home-manager = {
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.noname.imports = [
                inputs.stylix.homeModules.stylix
                inputs.nixvim.homeModules.nixvim
                ({ config, lib, pkgs, ... }:
                  let
                    homeDir = ./config/home;
                    staticDir = ./config/static;
                    dynamicDir = ./config/dynamic;
                    localBinDir = ./config/local-bin;

                    homeFiles = lib.mapAttrs' (name: _: lib.nameValuePair ".${name}" {
                      source = homeDir + "/${name}";
                    }) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir homeDir));


                    staticConfigFiles = lib.mapAttrs' (name: _: lib.nameValuePair name {
                      source = staticDir + "/${name}";
                    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir staticDir));

                    dynamicConfigFiles = lib.mapAttrs' (name: _: lib.nameValuePair name {
                      source = dynamicDir + "/${name}";
                      recursive = true;
                    }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dynamicDir));
                  in
                  {
                    nixpkgs.config = {
                      allowUnfree = true;
                      allowUnfreePredicate = (_: true);
                      allowAliases = true;
                    };

                    home.username = "noname";
                    home.homeDirectory = "/home/noname";
                    home.stateVersion = "26.05";
                    home.enableNixpkgsReleaseCheck = false;
                    home.packages = with pkgs; [
                      wechat
                      feishu
                      telegram-desktop
                      reaper
                      losslesscut-bin
                      glow
                      vivify
                      wev
                      termdown
                      aichat
                      baidupcs-go
                      imagemagick
                      glava
                      webcamoid
                      codegrab
                      yt-dlp
                      sqlite
                      duckdb
                      mariadb
                      delta
                      tesseract
                      pandoc
                      megacmd
                      csvlens
                      qsv
                      regex-tui
                      jqp
                      serve
                      drawy
                      mecab
                      translate-shell
                      wf-recorder
                      jrnl
                      slides
                      linux-wallpaperengine
                      sqlit-tui
                      libreoffice-still
                      kiro-cli
                      cronie
                      chafa
                      handlr
                      jetbrains.idea-oss
                      ncdu
                      wiki-tui
                      pastel
                      rustc
                      rustup
                      wasm-pack
                      lld
                      zig
                      hyprpicker
                      minio-client
                      television
                      dex
                      atuin
                      blesh
                      simple-completion-language-server
                      ruff
                      ty
                      typescript-language-server
                      vscode-css-languageserver
                      superhtml
                      nil
                      prettier
                      sqlfluff
                      gopls
                      zls
                      corefonts
                      vista-fonts
                      vista-fonts-chs
                      noto-fonts
                      noto-fonts-cjk-sans
                      noto-fonts-cjk-serif
                      noto-fonts-color-emoji
                      nerd-fonts.jetbrains-mono
                      sarasa-gothic
                      source-han-sans
                      source-han-mono
                      source-han-serif
                      nerd-fonts.caskaydia-cove
                      gitFull
                      jujutsu
                      jjui
                      nodejs
                      yarn
                      bun
                      pnpm
                      electron
                      typescript
                      prettier
                      eslint
                      sql-formatter
                      markdownlint-cli
                      stylelint
                      htmlhint
                    ];

                    home.file = homeFiles // {
                      ".local/bin" = {
                        source = localBinDir;
                        recursive = true;
                      };
                      ".npmrc".text = ''
                        prefix=${config.home.homeDirectory}/.npm-global
                        cache=${config.home.homeDirectory}/.npm
                        init-module=${config.home.homeDirectory}/.npm-init.js
                      '';
                    };

                    xdg.mime.enable = true;
                    xdg.desktopEntries = {
                      "glava" = {
                        name = "Glava";
                        exec = "glava -m wave";
                        terminal = false;
                        type = "Application";
                        categories = [ "Utility" "AudioVideo" ];
                      };
                    };
                    xdg.mimeApps = {
                      enable = true;
                      defaultApplications = {
                        "text/*" = "neovide.desktop";
                        "image/*" = "pqiv.desktop";
                        "video/*" = "mpv.desktop";
                        "audio/*" = "mpv.desktop";
                        "application/pdf" = "org.pwmt.zathura.desktop";
                        "x-scheme-handler/http" = "firefox.desktop";
                        "x-scheme-handler/https" = "firefox.desktop";
                        "x-scheme-handler/about" = "firefox.desktop";
                        "x-scheme-handler/unknown" = "firefox.desktop";
                      };
                    };
                    xdg.configFile = (staticConfigFiles // dynamicConfigFiles) // {
                      "mimeapps.list".force = true;
                    };

                    programs.home-manager.enable = true;
                    programs.gh = {
                      enable = true;
                      gitCredentialHelper.enable = true;
                    };
                    programs.firefox = {
                      enable = true;
                      profiles.noname = {
                        isDefault = true;
                        name = "noname";
                        settings = {
                          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
                          "ui.key.menuAccessKeyFocuses" = false;
                          "mousewheel.with_alt.action" = 0;
                          "privacy.resistFingerprinting" = false;
                          "privacy.fingerprintingProtection" = true;
                          "browser.zoom.siteSpecific" = false;
                        };
                        userChrome = ''
                          * {
                            box-shadow: none !important;
                            text-shadow: none !important;
                          }
                          #main-window {
                            min-width: 200px !important;
                          }
                          #urlbar-container,
                          #urlbar,
                          #search-container,
                          #nav-bar {
                            min-width: 1px !important;
                          }
                        '';
                      };
                    };
                    programs.alacritty = {
                      enable = true;
                      package = pkgs.alacritty-graphics;
                    };
                    programs.yazi = {
                      enable = true;
                      enableNushellIntegration = true;
                      shellWrapperName = "y";
                      settings = {
                        mgr.ratio = [ 0 2 3 ];
                        opener = {
                          play = [
                            { run = "handlr open %s1"; desc = "Play"; for = "linux"; orphan = true; }
                          ];
                          open = [
                            { run = "handlr open %s1"; desc = "Open"; for = "linux"; orphan = true; }
                          ];
                          reveal = [
                            { run = "handlr reveal %d1"; desc = "Reveal"; for = "linux"; orphan = true; }
                          ];
                        };
                      };
                      theme.icon = {
                        globs = [ ];
                        dirs = [ ];
                        files = [ ];
                        exts = [ ];
                        conds = [ ];
                      };
                    };
                    programs.zoxide = {
                      enable = true;
                      enableNushellIntegration = true;
                    };
                    programs.pqiv.enable = true;
                    programs.mpv = {
                      enable = true;
                      config = {
                        ao = "pulse";
                        keep-open = "yes";
                      };
                    };
                    programs.btop.enable = true;
                    programs.vesktop.enable = true;
                    programs.zathura = {
                      enable = true;
                      options.selection-clipboard = "clipboard";
                    };
                    programs.eza.enable = true;
                    programs.broot = {
                      enable = true;
                      enableNushellIntegration = true;
                      settings.modal = true;
                      settings.verbs = [
                        {
                          invocation = "edit";
                          key = "enter";
                          shortcut = "e";
                          execution = "$EDITOR {file}";
                          apply_to = "text_file";
                          leave_broot = false;
                        }
                      ];
                    };
                    programs.java.enable = true;
                    programs.go.enable = true;
                    programs.zed-editor = {
                      enable = true;
                      userSettings = {
                        features.copilot = false;
                        telemetry.metrics = false;
                        vim_mode = true;
                      };
                    };
                    programs.distrobox.enable = true;
                    programs.helix = {
                      enable = true;
                      settings = {
                        keys.normal = {
                          "A-w" = ":toggle-option soft-wrap.enable";
                          "A-a" = ":sh alacritty msg create-window --working-directory $(pwd)";
                          "A-s" = ":sh alacritty msg create-window --working-directory $(pwd) -e bash -ic y";
                          "C-r" = "redo";
                          "C-e" = "scroll_down";
                          "C-y" = "scroll_up";
                        };
                        keys.select = {
                          "A-w" = ":toggle-option soft-wrap.enable";
                          "A-a" = ":sh alacritty msg create-window --working-directory $(pwd)";
                          "A-s" = ":sh alacritty msg create-window --working-directory $(pwd) -e bash -ic y";
                          "C-e" = "scroll_down";
                          "C-y" = "scroll_up";
                        };
                        editor = {
                          gutters = [ "diff" ];
                          line-number = "relative";
                          auto-format = false;
                          auto-pairs = false;
                          default-yank-register = "+";
                          trim-trailing-whitespace = true;
                          trim-final-newlines = true;
                        };
                        editor.cursor-shape = {
                          insert = "bar";
                          normal = "block";
                          select = "underline";
                        };
                        editor.file-picker.hidden = false;
                        editor.soft-wrap.enable = true;
                        editor.indent-guides.render = true;
                        editor.smart-tab.enable = false;
                        editor.statusline.right = [ "diagnostics" "primary-selection-length" "selections" "position-percentage" "position" "total-line-numbers" "file-encoding" ];
                      };
                      languages = {
                        language-server.scls = {
                          command = "simple-completion-language-server";
                          config = {
                            feature_words = true;
                            feature_snippets = true;
                            snippets_first = true;
                            feature_paths = true;
                          };
                        };
                        language-server.jdtls = {
                          command = "jdtls";
                          timeout = 300;
                          config.java.maxConcurrentBuilds = 4;
                          args = [ "--jvm-arg=-Xms2G" "--jvm-arg=-Xmx8G" ];
                        };
                        language = [
                          {
                            name = "text";
                            scope = "text.plain";
                            file-types = [
                              "txt"
                              { glob = "README"; }
                              { glob = "CHANGELOG"; }
                              { glob = "LICENSE"; }
                            ];
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "python";
                            scope = "source.python";
                            language-servers = [ "ruff" "ty" "scls" ];
                          }
                          {
                            name = "java";
                            scope = "source.java";
                            language-servers = [ "scls" "jdtls" ];
                          }
                          {
                            name = "go";
                            scope = "source.go";
                            language-servers = [ "scls" "gopls" ];
                          }
                          {
                            name = "rust";
                            scope = "source.rust";
                            language-servers = [ "scls" "rust-analyzer" ];
                          }
                          {
                            name = "zig";
                            scope = "source.zig";
                            language-servers = [ "scls" "zls" ];
                          }
                          {
                            name = "c";
                            scope = "source.c";
                            language-servers = [ "scls" "clangd" ];
                          }
                          {
                            name = "javascript";
                            scope = "source.js";
                            language-servers = [ "typescript-language-server" "scls" ];
                          }
                          {
                            name = "typescript";
                            scope = "source.ts";
                            language-servers = [ "typescript-language-server" "scls" ];
                          }
                          {
                            name = "tsx";
                            scope = "source.tsx";
                            language-servers = [ "typescript-language-server" "scls" ];
                          }
                          {
                            name = "vue";
                            scope = "source.vue";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "sql";
                            scope = "source.sql";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "dockerfile";
                            scope = "source.dockerfile";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "yaml";
                            scope = "source.yaml";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "css";
                            scope = "source.css";
                            language-servers = [ "vscode-css-language-server" "scls" ];
                          }
                          {
                            name = "html";
                            scope = "source.html";
                            language-servers = [ "superhtml" "scls" ];
                          }
                          {
                            name = "json";
                            scope = "source.json";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "toml";
                            scope = "source.toml";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "xml";
                            scope = "source.xml";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "kdl";
                            scope = "source.kdl";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "bash";
                            scope = "source.bash";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "nix";
                            scope = "source.nix";
                            language-servers = [ "nil" "scls" ];
                          }
                          {
                            name = "markdown";
                            scope = "text.markdown";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "git-commit";
                            scope = "text.git-commit";
                            language-servers = [ "scls" ];
                          }
                          {
                            name = "jjdescription";
                            scope = "text.jjdescription";
                            language-servers = [ "scls" ];
                          }
                        ];
                      };
                    };
                    programs.hyprlock = {
                      enable = true;
                      settings = {
                        general.hide_cursor = true;
                        background = lib.mkForce [
                          {
                            path = "screenshot";
                            blur_passes = 3;
                            blur_size = 8;
                          }
                        ];
                        animations = {
                          bezier = "slowAcc, 0.60, 0.15, 0.10, 0.95";
                          animation = "inputFieldDots, 1, 10, slowAcc";
                        };
                        input-field = lib.mkForce {
                          outline_thickness = 0;
                          inner_color = "rgba(0, 0, 0, 0.0)";
                          size = "2000, 4000";
                          placeholder_text = "";
                          dots_size = 1;
                          dots_spacing = 1;
                          dots_center = true;
                          dots_text_format = "|";
                          font_color = "rgba(255, 255, 255, 1.0)";
                          fail_color = "rgba(0, 0, 0, 0.0)";
                          fail_text = "X";
                          check_color = "rgba(0, 0, 0, 0.0)";
                          position = "0, 0";
                          halign = "center";
                          valign = "center";
                        };
                        label = [
                          {
                            monitor = "";
                            text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
                            color = "rgba(255, 255, 255, 0.1)";
                            font_size = 500;
                            font_family = "Noto Sans Mono Bold";
                            position = "0, 0";
                            halign = "center";
                            valign = "center";
                          }
                          {
                            monitor = "";
                            text = "<span font_family='Noto Sans Mono Bold'>Hello $USER</span>";
                            color = "rgba(255, 255, 255, 0.5)";
                            font_size = 120;
                            position = "0, 400";
                            halign = "center";
                            valign = "center";
                          }
                          {
                            monitor = "";
                            text = ''cmd[update:60000] echo "<b> "$(uptime -p || ~/.config/scripts/UptimeNixOS.sh)" </b>"'';
                            color = "rgba(255, 255, 255, 0.2)";
                            font_size = 80;
                            font_family = "Noto Sans Mono Bold";
                            position = "0, -420";
                            halign = "center";
                            valign = "center";
                          }
                        ];
                      };
                    };
                    programs.nixvim = {
                      enable = true;
                      globals.mapleader = " ";
                      opts = {
                        number = false;
                        relativenumber = false;
                        clipboard = "unnamedplus";
                        wrap = true;
                        linebreak = true;
                        expandtab = true;
                        tabstop = 4;
                        shiftwidth = 4;
                        softtabstop = 4;
                        breakindent = true;
                        showbreak = "↪ ";
                        ambiwidth = "single";
                      };
                      autoCmd = [
                        {
                          event = [ "VimEnter" ];
                          pattern = [ "*" ];
                          command = "lua vim.schedule(function() vim.opt.laststatus = 0 end)";
                        }
                        {
                          event = [ "BufWritePre" ];
                          pattern = [ "*" ];
                          command = "%s/\\s\\+$//e";
                        }
                        {
                          event = [ "BufWritePre" ];
                          pattern = [ "*" ];
                          command = "%s/\\n\\+\\%$//e";
                        }
                      ];
                      keymaps = [
                        {
                          mode = "n";
                          key = "<Tab>";
                          action = "<cmd>bn<CR>";
                          options.desc = "Next buffer";
                        }
                        {
                          mode = "n";
                          key = "<S-Tab>";
                          action = "<cmd>bp<CR>";
                          options.desc = "Previous buffer";
                        }
                        {
                          mode = "n";
                          key = "<leader>x";
                          action = "<cmd>Bdelete<CR>";
                          options.desc = "Close buffer";
                        }
                        {
                          mode = "n";
                          key = "<leader>X";
                          action = "<cmd>Bdelete!<CR>";
                          options.desc = "Force close buffer";
                        }
                        {
                          mode = [ "n" "v" ];
                          key = "<A-w>";
                          action = "<cmd>set wrap!<CR>";
                          options.desc = "Toggle soft wrap";
                        }
                        {
                          mode = [ "n" "v" ];
                          key = "<A-i>";
                          action = "<cmd>let &laststatus = (&laststatus == 0 ? 2 : 0)<CR>";
                          options.desc = "Toggle lualine";
                        }
                        {
                          mode = [ "n" "v" ];
                          key = "<A-a>";
                          action = "<cmd>!alacritty msg create-window --working-directory $(pwd)<CR>";
                          options.desc = "Open new Alacritty window";
                        }
                        {
                          mode = [ "n" "v" ];
                          key = "<A-s>";
                          action = "<cmd>!alacritty msg create-window --working-directory $(pwd) -e bash -ic y<CR>";
                          options.desc = "Open new Yazi(Alacritty) window";
                        }
                        {
                          mode = "n";
                          key = "<leader>d";
                          action = "<cmd>lua vim.diagnostic.open_float()<CR>";
                          options.desc = "Show diagnostic";
                        }
                        {
                          mode = "n";
                          key = "[d";
                          action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
                          options.desc = "Previous diagnostic";
                        }
                        {
                          mode = "n";
                          key = "]d";
                          action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
                          options.desc = "Next diagnostic";
                        }
                        {
                          mode = "n";
                          key = "<leader>y";
                          action = "<cmd>Yazi<CR>";
                          options.desc = "Open Yazi";
                        }
                        {
                          mode = "n";
                          key = "<leader>f";
                          action = "<cmd>Telescope find_files<CR>";
                          options.desc = "Find files";
                        }
                        {
                          mode = "n";
                          key = "<leader>/";
                          action = "<cmd>Telescope live_grep<CR>";
                          options.desc = "Live grep";
                        }
                        {
                          mode = "n";
                          key = "<leader>b";
                          action = "<cmd>Telescope buffers<CR>";
                          options.desc = "Find buffers";
                        }
                        {
                          mode = [ "n" "x" ];
                          key = "s";
                          action = "<cmd>lua require('flash').jump()<CR>";
                          options.desc = "Flash jump";
                        }
                        {
                          mode = "n";
                          key = "<C-c>";
                          action = "<Plug>(comment_toggle_linewise_current)";
                          options.desc = "Toggle comment";
                        }
                        {
                          mode = "v";
                          key = "<C-c>";
                          action = "<Plug>(comment_toggle_linewise_visual)";
                          options.desc = "Toggle comment";
                        }
                        {
                          mode = "n";
                          key = "<leader>e";
                          action = "<cmd>NvimTreeToggle<CR>";
                          options.desc = "Toggle tree";
                        }
                      ];
                      plugins = {
                        cmp = {
                          enable = true;
                          mapping = {
                            "<C-n>" = "cmp.mapping.select_next_item()";
                            "<C-p>" = "cmp.mapping.select_prev_item()";
                            "<C-y>" = "cmp.mapping.confirm({ select = true })";
                          };
                          settings.sources = [
                            { name = "nvim_lsp"; }
                            { name = "path"; }
                            { name = "buffer"; }
                          ];
                          cmp-nvim-lsp.enable = true;
                          cmp-path.enable = true;
                          cmp-buffer.enable = true;
                        };
                        visual-multi = {
                          enable = true;
                          settings = {
                            maps = {
                              "Find Under" = "<C-n>";
                              "Add Cursor Down" = "<M-j>";
                              "Add Cursor Up" = "<M-k>";
                              "Select All" = "<C-m>";
                              "Visual All" = "<C-m>";
                              "Switch Mode" = "v";
                              "Goto Prev" = "<C-k>";
                              "Goto Next" = "<C-j>";
                            };
                            show_warnings = 1;
                            silent_exit = 0;
                          };
                        };
                        flash.enable = true;
                        yazi.enable = true;
                        web-devicons.enable = true;
                        which-key.enable = true;
                        gitsigns = {
                          enable = true;
                          settings = {
                            signs = {
                              add.text = "▌";
                              change.text = "▌";
                              changedelete.text = "▌";
                            };
                            current_line_blame = false;
                          };
                        };
                        guess-indent.enable = true;
                        telescope.enable = true;
                        lualine = {
                          enable = true;
                          settings.sections = {
                            lualine_a = [ "mode" ];
                            lualine_b = [ "diff" ];
                            lualine_c = [ "filename" ];
                            lualine_x = [ "encoding" ];
                            lualine_y = [ "progress" ];
                            lualine_z = [ "location" ];
                          };
                        };
                        lsp = {
                          enable = true;
                          servers = {
                            ruff.enable = true;
                            ty.enable = true;
                            gopls.enable = true;
                            zls.enable = true;
                          };
                        };
                        lspsaga = {
                          enable = true;
                          settings.lightbulb.enable = false;
                        };
                        nvim-surround.enable = true;
                        comment.enable = true;
                        treesitter = {
                          enable = true;
                          settings.highlight.enable = true;
                        };
                        nvim-tree = {
                          enable = true;
                          settings = {
                            renderer.group_empty = true;
                            git.enable = false;
                          };
                        };
                        bufdelete.enable = true;
                        oil.enable = true;
                        smear-cursor = {
                          enable = false;
                          settings = {
                            cursor_color = "#ff5a1f";
                            particles_enabled = true;
                            stiffness = 0.35;
                            trailing_stiffness = 0.12;
                            trailing_exponent = 6;
                            damping = 0.72;
                            gradient_exponent = 1.5;
                            gamma = 1;
                            never_draw_over_target = true;
                            hide_target_hack = true;
                            particle_spread = 1.5;
                            particles_per_second = 800;
                            particles_per_length = 50;
                            particle_max_lifetime = 800;
                            particle_max_initial_velocity = 25;
                            particle_velocity_from_cursor = 0.6;
                            particle_damping = 0.08;
                            particle_gravity = -40;
                            min_distance_emit_particles = 0;
                          };
                        };
                      };
                    };
                    programs.neovide.enable = true;

                    services.gpg-agent = {
                      enable = true;
                      defaultCacheTtl = 1800;
                      enableSshSupport = true;
                    };
                    services.mako = {
                      enable = true;
                      settings = {
                        layer = "overlay";
                        anchor = "bottom-center";
                        default-timeout = 3000;
                        height = 300;
                        "summary=\"Wayland Diagnose\"".invisible = 1;
                      };
                    };
                    services.tldr-update = {
                      enable = true;
                      package = pkgs.tealdeer;
                      period = "weekly";
                    };

                    i18n.inputMethod = {
                      enable = true;
                      type = "fcitx5";
                      fcitx5 = {
                        waylandFrontend = true;
                        addons = with pkgs; [
                          fcitx5-gtk
                          kdePackages.fcitx5-chinese-addons
                          fcitx5-pinyin-zhwiki
                          fcitx5-pinyin-moegirl
                          fcitx5-mozc
                        ];
                        settings = {
                          globalOptions = {
                            "Hotkey/TriggerKeys" = {
                              "0" = "Alt+space";
                              "1" = "Zenkaku_Hankaku";
                              "2" = "Hangul";
                            };
                            "Hotkey/AltTriggerKeys" = {
                              "0" = "Shift_L";
                            };
                            "Behavior" = {
                              resetStateWhenFocusIn = "No";
                              ShareInputState = "No";
                              DisabledAddons = "cloudpinyin";
                            };
                          };
                          inputMethod = {
                            "Groups/0" = {
                              Name = "Default";
                              "Default Layout" = "us";
                              DefaultIM = "pinyin";
                            };
                            "Groups/0/Items/0" = {
                              Name = "keyboard-us";
                              Layout = "";
                            };
                            "Groups/0/Items/1" = {
                              Name = "pinyin";
                              Layout = "";
                            };
                            "Groups/0/Items/2" = {
                              Name = "mozc";
                              Layout = "";
                            };
                            "GroupOrder" = {
                              "0" = "Default";
                            };
                          };
                          addons = {
                            classicui.globalSection = {
                              "Vertical Candidate List" = "True";
                            };
                            punctuation = {
                              globalSection = {
                                HalfWidthPuncAfterLetterOrNumber = "False";
                                TypePairedPunctuationsTogether = "False";
                                Enabled = "True";
                              };
                              sections.Hotkey = {
                                "0" = "Control+period";
                              };
                            };
                            pinyin.globalSection = {
                              PageSize = 7;
                              CloudPinyinEnabled = "True";
                              CloudPinyinIndex = 8;
                              CloudPinyinAnimation = "False";
                            };
                            cloudpinyin.globalSection = {
                              MinimumPinyinLength = 4;
                              Backend = "GoogleCN";
                            };
                          };
                        };
                      };
                    };

                    stylix = {
                      enable = true;
                      targets = {
                        qt.enable = true;
                        gtk.enable = true;
                        nixos-icons.enable = true;
                        firefox.profileNames = [ "noname" ];
                        cava = {
                          enable = true;
                          rainbow.enable = true;
                        };
                        alacritty.enable = true;
                        yazi.enable = true;
                        btop.enable = true;
                        vesktop.enable = true;
                        zathura.enable = true;
                        mako.enable = true;
                        fcitx5.enable = true;
                        nixvim.enable = true;
                        neovide.enable = true;
                        helix.enable = true;
                        zed.enable = true;
                      };
                      polarity = "dark";
                      base16Scheme = "${pkgs.base16-schemes}/share/themes/terracotta-dark.yaml";
                      cursor = {
                        package = pkgs.bibata-cursors;
                        name = "Bibata-Modern-Amber";
                        size = 24;
                      };
                      icons = {
                        enable = true;
                        package = pkgs.dracula-icon-theme;
                        dark = "Dracula";
                        light = "Dracula";
                      };
                      fonts = {
                        sizes = {
                          terminal = 14;
                          applications = 13;
                          popups = 13;
                        };
                        serif.name = "CaskaydiaCove Nerd Font";
                        sansSerif.name = "CaskaydiaCove Nerd Font";
                        monospace.name = "CaskaydiaCove Nerd Font";
                        emoji.name = "Noto Color Emoji";
                      };
                    };

                    programs.clock-rs = {
                      enable = true;
                      settings = {
                        general = {
                          color = "#${config.lib.stylix.colors.base02}";
                          interval = 250;
                          blink = false;
                          bold = true;
                        };
                        position = {
                          horizontal = "center";
                          vertical = "center";
                        };
                        date = {
                          fmt = "%A, %B %d, %Y";
                          use_12h = false;
                          utc = false;
                          hide_seconds = false;
                        };
                      };
                    };
                    programs.cava = {
                      enable = true;
                      settings = {
                        input = {
                          method = "pulse";
                          source = "auto";
                        };
                        smoothing.monstercat = 1;
                      };
                    };
                  })
              ];
            };

            system.stateVersion = "26.05";
          })
      ];
    };
  };
}
