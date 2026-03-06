## Bare Metal Installaton
## CPU -- i3 7020U

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

  nixpkgs.overlays = [
    self.overlays.default
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "intel-media-sdk-23.2.2"
  ];
  hardware.intelgpu = {
    driver = "i915";
    vaapiDriver = "intel-media-driver";
    computeRuntime = "legacy";
    mediaRuntime = "intel-media-sdk";
  };

  # System
  sapphire.system = {
    hostName = "phoenix";
    machineId = "9f3c7a2d8e1b4c6fa0d5e97b31c2a864";
    locale = "en_US.UTF-8";
    timeZone = "Asia/Kolkata";
    stateVersion = "25.11";
  };

  # Users
  sapphire.users = {
    cypher = {
      isAdmin = true;
      description = "Cypher";
      hashedPassword = "$6$7fad29ea$7HlcvyeGs6LLGTfhIVk.opyphoYrFWXKJxWC7CJKcUfhVg4B3l1xYCEOY9I7Ks3Z5oICOTwolOjkfevcTYTjI/";
    };
  };

  sapphire = {
    boot.enable = true;
    storage = {
      enable = true;
      disko = {
        enable = true;
        mainDisk.device = "/dev/---";
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
    desktop.niri = {
      enable = true;
      flavor = "dank-material-shell";
    };
  };
}
