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
  };
}
