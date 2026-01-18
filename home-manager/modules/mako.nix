{
  services.mako = {
    enable = true;
    settings = {
      layer = "overlay";
      anchor = "bottom-center";
      default-timeout = 3000;
      height = 300;
      "summary=\"Wayland Diagnose\"" = {
        invisible = 1;
      };
    };
  };
}
