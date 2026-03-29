{
  inputs,
  specs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  users.groups."secrets".members = builtins.attrNames specs.users;

  sops.age.keyFile = "/persist/system/var/lib/sops-nix/age-key.txt";

  sapphire.storage.impermanence.system.dirs = [
    "/var/lib/sops-nix"
  ];
}