{
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-hdd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    self.nixosModules.sapphire
    ./hardware-configuration.nix
  ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # nixpkgs.config.permittedInsecurePackages = [
  #   "intel-media-sdk-23.2.2"
  # ];
  hardware.intelgpu = {
    driver = "i915";
    vaapiDriver = "intel-media-driver";
    computeRuntime = "legacy";
    # mediaRuntime = "intel-media-sdk";
  };

  # System
  sapphire.nixos.system = {
    hostName = "atlas";
    machineId = "7c2a19f5e3b84d62a1c90f5e8b42d71a";
    locale = "en_US.UTF-8";
    timeZone = "Asia/Kolkata";
    stateVersion = "25.11";
  };

  # Users
  sapphire.nixos.users = {
    cypher = {
      isAdmin = true;
      description = "Cypher";
      hashedPassword = "$6$7fad29ea$7HlcvyeGs6LLGTfhIVk.opyphoYrFWXKJxWC7CJKcUfhVg4B3l1xYCEOY9I7Ks3Z5oICOTwolOjkfevcTYTjI/";
    };
  };

  sapphire.nixos = {
    boot.enable = true;
    storage = {
      enable = true;
      disko = {
        enable = true;
        mainDisk.device = "/dev/vda";
        luksEncryption.enable = true;
        compression.enable = true;
        swap = {
          enable = true;
          size = "16G";
        };
      };
      impermanence = {
        enable = true;
        # system = {
        #   dirs = [];
        #   files = [];
        # };
        # users = {
        #   shared = {
        #     dirs = [];
        #     files = [];
        #   };
        # };
        # perUser.cypher = {
        #   dirs = [];
        #   files = [];
        # };
      };
    };
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
    # services.openssh = {
    #   enable = true;
    #   perUserPublicKeys = {
    #     cypher = [];
    #   };
    # };
  };
}
