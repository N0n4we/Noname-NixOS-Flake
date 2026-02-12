{ config, pkgs, lib, ... }:
{
  environment.variables = {
    EDITOR = "hx";
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
    PATH = lib.mkAfter "${config.users.users.noname.home}/.npm-global/bin";
    ELECTRON_OVERRIDE_DIST_PATH = "${pkgs.electron}/bin";
  };
}
