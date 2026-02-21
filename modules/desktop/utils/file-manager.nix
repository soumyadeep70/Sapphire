{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.sapphire.desktop.utils.fileManager;
in
{
  options.sapphire.desktop.utils.fileManager =
    let
      mkFMOptions =
        names:
        lib.genAttrs names (
          name:
          (lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkEnableOption "${name} file manager";
                makeDefault = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Whether to make ${name} the default file manager";
                  example = true;
                };
              };
            };
            default = { };
            description = "multiple file-manager providers config";
          })
        );
    in
    {
      enable = lib.mkEnableOption ''
        file-manager module (installs and configure multiple file-managers)
      '';
      providers = lib.mkOption {
        type = lib.types.submodule {
          options = mkFMOptions [
            "yazi"
            "thunar"
          ];
        };
        default = { };
        description = "file-manager (desktop utility) config";
      };
    };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = (lib.count (x: cfg.providers.${x}.makeDefault) (builtins.attrNames cfg.providers)) <= 1;
            message = "One file-manager can be made default";
          }
        ];
      }
      (lib.mkIf cfg.providers.yazi.enable {
        programs.yazi.enable = true;
        # TODO: add settings, plugins, flavours etc
      })
      (lib.mkIf cfg.providers.thunar.enable {
        programs.thunar = {
          enable = true;
          plugins = with pkgs; [
            thunar-archive-plugin
            thunar-volman
            thunar-vcs-plugin
            thunar-media-tags-plugin
          ];
        };
        services.gvfs.enable = true;
        services.tumbler.enable = true;
        environment.systemPackages = [
          pkgs.file-roller
        ];
        sapphire.storage.impermanence.users.shared = {
          dirs = [
            "@configHome/Thunar"
            "@dataHome/gvfs-metadata"
          ];
          files = [
            "@configHome/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
          ];
        };
      })
      (
        let
          defaultProvider = lib.findFirst (x: cfg.providers.${x}.makeDefault) null (
            builtins.attrNames cfg.providers
          );

          desktopFiles = {
            yazi = "yazi.desktop";
            thunar = "thunar.desktop";
          };
        in
        lib.mkIf (defaultProvider != null) {
          home-manager.sharedModules = lib.singleton {
            xdg.mimeApps.defaultApplications = {
              "inode/directory" = lib.mkBefore [ desktopFiles.${defaultProvider} ];
            };
          };
        }
      )
    ]
  );
}
