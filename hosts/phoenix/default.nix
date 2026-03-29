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

  nixpkgs.config.permittedInsecurePackages = [
    "intel-media-sdk-23.2.2"
  ];
  hardware.intelgpu = {
    driver = "i915";
    vaapiDriver = "intel-media-driver";
    computeRuntime = "legacy";
    mediaRuntime = "intel-media-sdk";
  };

  sapphire = {
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
    # services.openssh = {
    #   enable = true;
    #   perUserPublicKeys = {
    #     cypher = [];
    #   };
    # };
  };
}
