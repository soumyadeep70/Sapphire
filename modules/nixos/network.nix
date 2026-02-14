{
  lib,
  config,
  ...
}:
let
  cfg = config.sapphire.nixos.network;

  extractPort =
    portStr:
    let
      match = builtins.match "^[[:space:]]*([1-9][0-9]{0,4})[[:space:]]*$" portStr;
      port = if match != null then lib.toInt (builtins.head match) else null;
    in
    if port != null && port < 65536 then port else null;

  extractPortRange =
    rangeStr:
    let
      ports = lib.splitString "-" rangeStr;
    in
    if (builtins.length ports) != 2 then
      null
    else
      let
        first = extractPort (builtins.head ports);
        second = extractPort (builtins.elemAt ports 1);
      in
      if first != null && second != null && first <= second then
        {
          from = first;
          to = second;
        }
      else
        null;

  groupPortsAndPortRanges =
    portList:
    let
      list = map (
        x:
        let
          port = extractPort x;
          portRange = extractPortRange x;
        in
        if port != null then
          port
        else if portRange != null then
          portRange
        else
          x
      ) portList;
      groups = builtins.groupBy (
        x:
        if (builtins.typeOf x) == "int" then
          "port"
        else if (builtins.typeOf x) == "set" then
          "portRange"
        else
          "invalid"
      ) list;
    in
    if builtins.hasAttr "invalid" groups then
      throw "Invalid port(s) or port range(s) detected: ${lib.concatStringsSep ", " groups.invalid}"
    else
      {
        ports = groups.port or [ ];
        portRanges = groups.portRange or [ ];
      };
in
{
  options.sapphire.nixos.network = {
    enable = lib.mkEnableOption "networking (networkmanager)";

    firewall = {
      enable = lib.mkEnableOption "firewall";
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Specify ports to open for incoming TCP traffic";
        example = [
          "80"
          "443"
          "1000-2000"
          "1-100"
        ];
      };
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Specify ports to open for incoming UDP traffic";
        example = [
          "80"
          "443"
          "1000-2000"
          "1-100"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    sapphire.nixos.users.shared.extraGroups = [ "networkmanager" ];

    networking.firewall = lib.mkIf cfg.firewall.enable (
      let
        TCPPorts = groupPortsAndPortRanges cfg.firewall.allowedTCPPorts;
        UDPPorts = groupPortsAndPortRanges cfg.firewall.allowedUDPPorts;
      in
      {
        enable = true;
        allowedTCPPorts = TCPPorts.ports;
        allowedTCPPortRanges = TCPPorts.portRanges;
        allowedUDPPorts = UDPPorts.ports;
        allowedUDPPortRanges = UDPPorts.portRanges;
      }
    );

    sapphire.nixos.system.extraPersistentDirs = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
