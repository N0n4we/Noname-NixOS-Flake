{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {
      noname = {
        isDefault = true;
        name = "noname";
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "ui.key.menuAccessKeyFocuses" = false;
          "mousewheel.with_alt.action" = 0;
          "privacy.resistFingerprinting" = true;
        };
        userChrome = ''
          * {
            box-shadow: none !important;
            text-shadow: none !important;
          }
        '';
      };
    };
  };
}
