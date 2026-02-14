{
  inputs,
  self,
  pkgs,
  ...
}:
{
  imports = [
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-hdd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    self.nixosModules.sapphire
  ];

  # hardware.intelgpu = {
  #   driver = "i915";
  #   vaapiDriver = "intel-media-driver";
  #   computeRuntime = "legacy";
  # };

  # nixpkgs.config.permittedInsecurePackages = [
  #   "intel-media-sdk-23.2.2"
  # ];
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
      # intel-media-sdk
      intel-compute-runtime-legacy1
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
    ];
  };

  # System
  sapphire.nixos.system = {
    hostName = "atlas";
    machineId = "7c2a19f5e3b84d62a1c90f5e8b42d71a";
    locale = "en_US.UTF-8";
    timeZone = "Asia/Kolkata";
    # extraPersistentDirs = [];
    # extraPersistentFiles = [];
    stateVersion = "25.11";
  };

  # Users
  sapphire.nixos.users = {
    # shared = {
    #   extraPersistentDirs = [];
    #   extraPersistentFiles = [];
    #   extraGroups = [];
    # };
    perUser = {
      cypher = {
        isAdmin = true;
        description = "Cypher";
        hashedPassword = "$6$7fad29ea$7HlcvyeGs6LLGTfhIVk.opyphoYrFWXKJxWC7CJKcUfhVg4B3l1xYCEOY9I7Ks3Z5oICOTwolOjkfevcTYTjI/";
        # extraPersistentDirs = [];
        # extraPersistentFiles = [];
        # extraGroups = [];
      };
    };
  };

  sapphire.nixos = {
    boot.enable = true;
    storage = {
      enable = true;
      mainDisk = {
        device = "/dev/vda";
        swapSize = "4G";
      };
    };
    impermanence.enable = true;
    nix.enable = true;
    hardware = {
      enableAllFirmware = true;
      enableFwupd = true;
      enableGraphicsDrivers = true;
      enableBluetooth = true;
      enableMultimedia = true;
      enableUtils = true;
    };
    network = {
      enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };
    };
    security.enable = true;
  };
}
