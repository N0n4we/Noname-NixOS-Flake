{ lib, ... }:
let
  configDir = ./config;
  homeDir = configDir + "/home";
  staticDir = configDir + "/static";
  dynamicDir = configDir + "/dynamic";

  homeFiles = lib.mapAttrs' (name: _: lib.nameValuePair ".${name}" {
    source = homeDir + "/${name}";
  }) (lib.filterAttrs (_: type: type == "regular") (builtins.readDir homeDir));

  localBinDir = configDir + "/local-bin";

  staticConfigFiles = lib.mapAttrs' (name: _: lib.nameValuePair name {
    source = staticDir + "/${name}";
  }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir staticDir));

  dynamicConfigFiles = lib.mapAttrs' (name: _: lib.nameValuePair name {
    source = dynamicDir + "/${name}";
    recursive = true;
  }) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir dynamicDir));
in
{
  home.file = homeFiles // {
    ".local/bin" = {
      source = localBinDir;
      recursive = true;
    };
  };

  xdg.configFile = staticConfigFiles // dynamicConfigFiles;
}
