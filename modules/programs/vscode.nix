{
  lib,
  pkgs,
  ...
}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  home-manager.sharedModules = lib.singleton {
    programs.vscode = {
      enable = true;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          tobiasalthoff.atom-material-theme
          pkief.material-icon-theme
          jnoortheen.nix-ide
          tamasfe.even-better-toml
        ];
        userSettings = {
          "editor.fontFamily" = "JetBrainsMono Nerd Font";
          "editor.fontLigatures" = true;
          "workbench.colorTheme" = "Atom Material Theme";
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.startupEditor" = "none";
          "files.autoSave" = "afterDelay";
          "security.workspace.trust.enabled" = false;
          
          # Nix IDE
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
        };
      };
    };
    home.packages = with pkgs; [
      nixd
    ];
  };
}