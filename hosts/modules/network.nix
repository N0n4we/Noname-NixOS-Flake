{ pkgs, lib, ... }:
let
    pullSubsScript = pkgs.writeShellScript "mihomo-sub.sh" (builtins.readFile ./mihomo-sub.sh);
in
{
    networking = {
        hostName = ""; # do not set Static hostname
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
    services.avahi.enable = false;
    environment.systemPackages = with pkgs; [
        wirelesstools
        networkmanager
        networkmanagerapplet
        dnsutils
        macchanger
    ];
    services.mihomo = {
        enable = true;
        tunMode = true;
        webui = pkgs.metacubexd;
        configFile = ./mihomo.yaml;
    };

    # 如内核把 BBR 编译成模块，确保它会被加载
    boot.kernelModules = [ "tcp_bbr" ];
    # 通过 sysctl 设置拥塞控制算法（以及 fq 队列）
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # 在 initrd 阶段生成临时 ID 到 /run
    boot.initrd.postResumeCommands = lib.mkAfter ''
        if [ ! -f /run/machine-id ]; then
            ${pkgs.systemd}/bin/systemd-id128 new > /run/machine-id
        fi
    '';
    # 建立软链接
    environment.etc."machine-id".source = "/run/machine-id";
    # 禁止将 ID 写入磁盘
    systemd.services.systemd-machine-id-commit.enable = false;

    # --- 统一的身份混淆服务 (Hostname + DMI + MAC) ---
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

            # --- 辅助函数：生成随机十六进制 ---
            rand_hex() {
                head -c "$1" /dev/urandom | od -An -tx1 | tr -d ' \n'
            }

            # --- 辅助函数：执行 DMI 伪装 ---
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
                0) # Lenovo ThinkPad X1 Carbon Gen 9
                    NEW_HOSTNAME="thinkpad-$(rand_hex 2)"
                    VENDOR="LENOVO"
                    MODEL="20XW002JUS"
                    VERSION="ThinkPad X1 Carbon Gen 9"
                    ;;
                1) # Dell XPS 13 9310
                    NEW_HOSTNAME="xps-$(rand_hex 2)"
                    VENDOR="Dell Inc."
                    MODEL="XPS 13 9310"
                    VERSION="1.4.0"
                    ;;
                2) # Framework Laptop 13
                    NEW_HOSTNAME="framework-$(rand_hex 2)"
                    VENDOR="Framework"
                    MODEL="Laptop (13th Gen Intel Core)"
                    VERSION="A4"
                    ;;
                3) # ASUS Generic Desktop
                    NEW_HOSTNAME="desktop-$(rand_hex 2)"
                    VENDOR="ASUSTeK COMPUTER INC."
                    MODEL="TUF GAMING B550M-PLUS"
                    VERSION="Rev X.0x"
                    ;;
                4) # System76 Lemur Pro
                    NEW_HOSTNAME="pop-os-$(rand_hex 2)"
                    VENDOR="System76"
                    MODEL="Lemur Pro"
                    VERSION="lemp10"
                    ;;
                5) # ASUS ROG Zephyrus G14
                    NEW_HOSTNAME="rog-$(rand_hex 2)"
                    VENDOR="ASUSTeK COMPUTER INC."
                    MODEL="GA401IV"
                    VERSION="1.0"
                    ;;
                6) # HP EliteBook 840 G8
                    NEW_HOSTNAME="hp-elitebook-$(rand_hex 2)"
                    VENDOR="HP"
                    MODEL="HP EliteBook 840 G8 Notebook PC"
                    VERSION="SBKPF1.23"
                    ;;
                7) # Intel NUC 11
                    NEW_HOSTNAME="nuc-server-$(rand_hex 2)"
                    VENDOR="Intel Corporation"
                    MODEL="NUC11PAHi7"
                    VERSION="M90a"
                    ;;
                8) # 联想小新 Pro 14 2022
                    NEW_HOSTNAME="ideapad-$(rand_hex 2)"
                    VENDOR="LENOVO"
                    MODEL="82L7"
                    VERSION="Xiaoxin Pro 14 IAP 2022"
                    ;;
                9) # 联想拯救者 Y9000P 2023
                    NEW_HOSTNAME="legion-$(rand_hex 2)"
                    VENDOR="LENOVO"
                    MODEL="82WK"
                    VERSION="Legion Y9000P IAH7H"
                    ;;
                10) # 华为 MateBook X Pro 2022
                    NEW_HOSTNAME="matebook-$(rand_hex 2)"
                    VENDOR="HUAWEI"
                    MODEL="MRGFG-XX"
                    VERSION="M1030"
                    ;;
                11) # 华为 MateBook 14s
                    NEW_HOSTNAME="huawei-$(rand_hex 2)"
                    VENDOR="HUAWEI"
                    MODEL="HKF-XX"
                    VERSION="M1020"
                    ;;
                12) # 小米笔记本 Pro 15 2022
                    NEW_HOSTNAME="mi-notebook-$(rand_hex 2)"
                    VENDOR="TIMI"
                    MODEL="TM2113"
                    VERSION="Xiaomi Notebook Pro 15 2022"
                    ;;
                13) # RedmiBook Pro 14
                    NEW_HOSTNAME="redmibook-$(rand_hex 2)"
                    VENDOR="TIMI"
                    MODEL="TM2019"
                    VERSION="RedmiBook Pro 14"
                    ;;
                14) # 荣耀 MagicBook 14 2022
                    NEW_HOSTNAME="magicbook-$(rand_hex 2)"
                    VENDOR="HONOR"
                    MODEL="GLO-G56"
                    VERSION="MagicBook 14 2022"
                    ;;
                15) # 神舟战神 Z8-DA5NP
                    NEW_HOSTNAME="hasee-$(rand_hex 2)"
                    VENDOR="Hasee Computer"
                    MODEL="Z8-DA5NP"
                    VERSION="Standard"
                    ;;
                16) # 机械革命 蛟龙16K
                    NEW_HOSTNAME="mechrevo-$(rand_hex 2)"
                    VENDOR="MECHREVO"
                    MODEL="JL16K"
                    VERSION="V1.0"
                    ;;
                17) # 七彩虹 将星X15 AT
                    NEW_HOSTNAME="colorful-$(rand_hex 2)"
                    VENDOR="Colorful Technology"
                    MODEL="X15 AT 23"
                    VERSION="V1.0"
                    ;;
                18) # 惠普 战66五代
                    NEW_HOSTNAME="hp-zhan-$(rand_hex 2)"
                    VENDOR="HP"
                    MODEL="HP ProBook 440 G9"
                    VERSION="KBC Version 53.27.00"
                    ;;
                19) # 惠普 暗影精灵8
                    NEW_HOSTNAME="omen-$(rand_hex 2)"
                    VENDOR="HP"
                    MODEL="OMEN by HP Laptop 16-b1xxx"
                    VERSION="98.33"
                    ;;
                20) # 戴尔 游匣 G15
                    NEW_HOSTNAME="dell-g15-$(rand_hex 2)"
                    VENDOR="Dell Inc."
                    MODEL="Dell G15 5520"
                    VERSION="1.10.0"
                    ;;
                21) # 微星 冲锋坦克 Katana GF66
                    NEW_HOSTNAME="msi-katana-$(rand_hex 2)"
                    VENDOR="Micro-Star International Co., Ltd."
                    MODEL="Katana GF66 12UE"
                    VERSION="REV:1.0"
                    ;;
                22) # 华硕 天选4
                    NEW_HOSTNAME="asus-tianxuan-$(rand_hex 2)"
                    VENDOR="ASUSTeK COMPUTER INC."
                    MODEL="FA507UV"
                    VERSION="1.0"
                    ;;
                23) # 联想 ThinkBook 14+ 2023
                    NEW_HOSTNAME="thinkbook-$(rand_hex 2)"
                    VENDOR="LENOVO"
                    MODEL="21J2"
                    VERSION="ThinkBook 14+ IAP"
                    ;;
                24) # 联想 YOGA 14s 2022
                    NEW_HOSTNAME="yoga-$(rand_hex 2)"
                    VENDOR="LENOVO"
                    MODEL="82QE"
                    VERSION="Yoga Pro 14s IAH7"
                    ;;
                25) # 宏碁 非凡 S3
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

                if ip link show "$iface_name" > /dev/null 2>&1; then
                    echo "  -> Randomizing MAC for interface: $iface_name"

                    ip link set dev "$iface_name" down

                    # -r or -A
                    macchanger -r "$iface_name"

                    ip link set dev "$iface_name" up
                fi
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
        script = "${pullSubsScript}";
    };
}
