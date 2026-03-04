_: {
  imports = [
    ./niri
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
}
