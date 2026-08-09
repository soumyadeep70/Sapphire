{
  lib,
  pkgs,
  ...
}:
{
  # Allow CPU profiling
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = -1;
    "kernel.kptr_restrict" = 0;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  home-manager.sharedModules = lib.singleton (_: {
    programs.vscode.enable = true;

    home.packages = with pkgs; [
      antigravity-fhs
      zed-editor-fhs
      jetbrains.clion
    ];
  });

  nixdesk.core.storage.systemDisk.impermanence.user.dirs = [
    "@configHome/Code"
    "@configHome/Antigravity"
    "@configHome/zed"
    "@configHome/JetBrains"
  ];
}
