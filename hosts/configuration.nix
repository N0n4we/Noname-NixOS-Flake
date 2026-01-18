{ inputs, pkgs, ... }:
let
  moduleDir = ./modules;
  moduleFiles = builtins.attrNames (builtins.readDir moduleDir);
  nixModules = builtins.filter (name: builtins.match ".*\\.nix$" name != null) moduleFiles;
  modulePaths = map (name: moduleDir + "/${name}") nixModules;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./system-packages.nix
      ./modules/secret.nix
    ] ++ modulePaths;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
    allowAliases = true;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
  };

  # 递归保留所有 Flake 输入及其依赖的源码，防止 GC 删除
  # 确保断网时也能 rebuild 系统
  system.extraDependencies = let
    collectFlakeInputs = input:
      [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));
  in
    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs)
    ++ [ pkgs.stdenvNoCC ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # # --- VM Optimizations ---
  # boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_net" "virtio_pci" "virtio_rng" "virtio_scsi" ];
  # services.xserver.videoDrivers = [ "virtio" ];
  # services.qemuGuest.enable = true;
  # # ------------------------

  # 启用 Mesa 驱动以支持 OpenGL / 3D 加速
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ];
  };

  hardware.i2c.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  system.stateVersion = "25.05";

}
