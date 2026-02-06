{ pkgs, inputs, ... }:
let
  moduleDir = ./modules;
  moduleFiles = builtins.attrNames (builtins.readDir moduleDir);
  nixModules = builtins.filter (name: builtins.match ".*\\.nix$" name != null) moduleFiles;
  modulePaths = map (name: moduleDir + "/${name}") nixModules;
in
{
  imports = [
    inputs.stylix.homeModules.stylix
    ./config.nix
  ] ++ modulePaths;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      allowAliases = true;
    };
  };

  home.username = "noname";
  home.homeDirectory = "/home/noname";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  home.enableNixpkgsReleaseCheck = false;
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
  # system-wide /run/current-system/sw/share/applications/
  # user-wide /etc/profiles/per-user/noname/share/applications/
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "neovide.desktop";
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
  xdg.configFile."mimeapps.list".force = true;

  home.packages = with pkgs; [
    # instant message
    telegram-desktop
    gajim

    # music production
    reaper

    # personal packages
    losslesscut-bin
    glow
    wev
    termdown
    aichat
    baidupcs-go
    imagemagick
    glava
    webcamoid
    codegrab
    opencode
    yt-dlp
    sqlite
    duckdb
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
    claude-code
    cronie
    chafa
    handlr
    jetbrains.idea-oss
    jetbrains.jdk
    ncdu

    # LSP & Formatter
    simple-completion-language-server
    ruff
    ty
    typescript-language-server
    vscode-css-languageserver
    superhtml
    nil
    prettier
    sqlfluff
  ];
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty-graphics;
    settings = {
      terminal.shell = { program = "nu"; };
    };
  };
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        ratio = [0 2 3];
      };
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
    theme = {
      icon = {
        globs = [];
        dirs = [];
        files = [];
        exts = [];
        conds = [];
      };
    };
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.nushell = {
    enable = true;
    shellAliases = {
      core-ls = "ls";
      ls = "eza --icons --group-directories-first";
      ll = "eza -lbF --git --icons --total-size --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      z2j = "trans -4 -s zh -t ja";
      z2e = "trans -4 -s zh -t en";
      e2z = "trans -4 -s en -t zh";
      e2j = "trans -4 -s en -t ja";
      j2z = "trans -4 -s ja -t zh";
      j2e = "trans -4 -s ja -t en";
      j = "jrnl";
      nu = "alacritty msg create-window --working-directory (pwd) -e nu";
      bash = "alacritty msg create-window --working-directory (pwd) -e bash";
    };
    extraConfig = ''
      def --env y [...args] {
      	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
      	yazi ...$args --cwd-file $tmp
      	let cwd = (open $tmp)
      	if $cwd != "" and $cwd != $env.PWD {
      		cd $cwd
      	}
      	rm -fp $tmp
      }
      $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.local/bin" | uniq)
    '';
    settings = {
      history = {
        file_format = "sqlite";
        max_size = 1000000;
        sync_on_enter = true;
        isolation = false;
      };
      show_banner = false;
    };
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
    options = {
      selection-clipboard = "clipboard";
    };
  };
  programs.eza.enable = true;
  services.tldr-update = {
    enable = true;
    package = pkgs.tealdeer;
    period = "weekly";
  };
}
