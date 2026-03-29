{
  lib,
  ...
}:
{
  imports = [
    ./dank-material-shell
  ];

  options.sapphire.desktop.settings = {
    monitors = lib.mkOption {
      type =
        with lib.types;
        attrsOf (submodule {
          options =
            { name, ... }:
            {
              identifier = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = ''
                  connector name (eg. HDMI-A-1) or monitor manufacturer,
                  model, and serial, separated by a single space each
                  (eg. BNQ BenQ GW2790 S1R0259701Q).
                  Defaults to the attribute key name
                '';
                example = "eDP-1";
              };
              mode = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    width = lib.mkOption {
                      type = lib.types.int;
                      description = "Pixel width of the monitor";
                    };
                    height = lib.mkOption {
                      type = lib.types.int;
                      description = "Pixel height of the monitor";
                    };
                    refresh = lib.mkOption {
                      type = lib.types.float;
                      description = "Refresh rate of the monitor";
                    };
                  };
                };
                description = "monitor mode";
              };
              scale = lib.mkOption {
                type = lib.types.float;
                default = 1.0;
                description = "monitor resolution scaling";
                example = "1.5";
              };
              transform = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    flipped = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Whether  to flip the output";
                      example = true;
                    };
                    rotation = lib.mkOption {
                      type = lib.types.enum [
                        0
                        90
                        180
                        270
                      ];
                      default = 0;
                      description = "Counter-clockwise rotation of this output in degrees";
                      example = 270;
                    };
                  };
                };
                default = { };
                description = "monitor output transform";
              };
              position = lib.mkOption {
                type =
                  with lib.types;
                  nullOr (submodule {
                    options = {
                      x = lib.mkOption {
                        type = lib.types.int;
                        description = "the x co-ordinate";
                      };
                      y = lib.mkOption {
                        type = lib.types.int;
                        description = "the y co-ordinate";
                      };
                    };
                  });
                default = null;
                description = "Position of the output in the global coordinate space";
              };
            };
        });
      default = { };
      description = "monitor config";
    };
  };
}
