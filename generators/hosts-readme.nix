_:

''
  # Device-Specific Hardware Profiles

  This repository defines how to build device-specific hardware profiles based on CPU, GPU, and other components. Profiles are used to enable and install curated and optimized services and drivers instead of relying on generic defaults.


  ## CPU

  ### Intel CPU
  ```nix
  # Don't enable Model-Specific-Registers (enabling it increases security risk)
  hardware.cpu.x86.msr = ...;

  # Always enable microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Don't enable Intel Software-Guard-Extensions (usually meant for servers)
  hardware.cpu.intel.sgx.provision = ...;
  ```

  ### AMD CPU
  ```nix
  # Don't enable Model-Specific-Registers (enabling it increases security risk)
  hardware.cpu.x86.msr = ...;

  # Always enable microcode updates
  hardware.cpu.amd.updateMicrocode = true;

  # Don't enable AMD Secure-Encrypted-Virtualization (usually meant for servers)
  hardware.cpu.amd.sev = ...;         # For host
  hardware.cpu.amd.sevGuest = ...;    # for Guest VM

  # Keep it disabled unless you want to overclock/underclock the CPU
  # Warning: Enabling this voids AMD product warranty !!!
  hardware.cpu.amd.ryzen-smu.enable = false;
  ```

  ## GPU

  ### Intel GPU

  #### Kernel Drivers

  > [!WARNING]
  > **Don't change default kernel driver unless you know what you're doing.**

  Linux currently provides two kernel drivers for Intel GPUs:

  - `i915` -> the stable, long-standing driver (default)
  - `xe` -> the next-generation driver introduced in **Linux 6.8**

  The `xe` driver introduced in kernel version **6.8** and primarily targets **Intel Arc (Alchemist+) and newer Xe-based platforms**. Even though `xe` driver support Tiger Lake and newer, the support is experimental and generally not recommended. See [here](https://dgpu-docs.intel.com/devices/hardware-table.html#gpus-with-supported-drivers).

  ```nix
  # Force xe driver over i915 on GPU with PCI ID 8086:9A78
  boot.kernelParams = [
    "xe.force_probe=9A78"
    "i915.force_probe=!9A78"
  ];
  ```
  Replace `9A78` with your GPU’s PCI device ID. You can obtain the PCI device ID using:
  ```bash
  lspci -nn | grep -E "VGA|3D|Display"
  ```

  or directly from sysfs:
  ```bash
  cat /sys/class/drm/card0/device/device
  ```
  > [!IMPORTANT]
  > Using `force_probe` taints the kernel and may break suspend, media acceleration, or Vulkan. This should only be used for testing or development and removed once native support is available.

  #### Userspace Drivers

  Enable the graphics stack:
  ```nix
  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # Optional
  };
  ```
  Then add the appropriate packages to `hardware.graphics.extraPackages`
  (and `hardware.graphics.extraPackages32` if needed), depending on your GPU. Check driver support by visiting the corresponding links.

  | Driver Name  | extraPackages | extraPackages32 | Comment |
  | --------------| :-------------:| :---------------:| :--------|
  | [`media-driver`](https://github.com/intel/media-driver?tab=readme-ov-file#supported-platforms) | pkgs.intel-media-driver | pkgs.driversi686Linux.intel-media-driver | **Standard:** VA-API support for Gen8+ iGPUs (5th-14th Gen Core, including newer Core, Core Ultra series), plus all Xe-based dGPUs (DG1, DG2/Arc, BMG). |
  | `vaapi-driver` | pkgs.intel-vaapi-driver | pkgs.driversi686Linux.intel-vaapi-driver | **Legacy:** supports pre-Gen8 iGPUs(pre 5th Gen Core) only. **Do not install alongside `media-driver`.** |
  | [`vpl-gpu-rt`](https://github.com/intel/vpl-gpu-rt#how-to-use) | pkgs.vpl-gpu-rt | - | **Standard:** Intel QSV / oneVPL runtime for Gen12+ iGPUs (11th–14th Gen Core, including newer Core, Core Ultra series), plus all Xe-based dGPUs (DG1, DG2/Arc, BMG).|
  | [`media-sdk`](https://github.com/Intel-Media-SDK/MediaSDK#media-sdk-support-matrix) | pkgs.intel-media-sdk | - | **Legacy:** Deprecated in favour of `vpl-gpu-rt`. Supports Gen8 to Gen12 (12.0) iGPUs (5th-11th Gen Core), some Atom/Pentium/Celeron and only early Xe dGPUs (DG1 / SG1). |
  | [`compute-runtime`](https://github.com/intel/compute-runtime#supported-platforms) | pkgs.intel-compute-runtime | - | **Standard:** OpenCL and Level Zero support for Gen12+ iGPUs (11th–14th Gen Core, including newer Core, Core Ultra series), plus all Xe-based dGPUs (DG1, DG2/Arc, BMG). |
  | [`compute-runtime-legacy`](https://github.com/intel/compute-runtime/blob/master/LEGACY_PLATFORMS.md#supported-legacy-platforms) | pkgs.intel-compute-runtime-legacy1 | - | **Legacy:** Supports Gen8 to Gen11 iGPUs (5th-10th Gen Core), and some Atom/Pentium/Celeron iGPUs. **Do not mix with modern runtime.** |

  ### AMD GPU
  > [!NOTE]
  > currently no docs

  ### NVIDIA GPU
  > [!NOTE]
  > currently no docs

  ####

  ## Storage

  ```nix
  # Enable Hard Drive Active Protection System Daemon (if HDD exists)
  services.hdapsd.enable = true;

  # Enable periodic SSD TRIM (if SSD exists)
  services.fstrim.enable = true;
  ```
''
