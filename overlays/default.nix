_: {
  flake.overlays.default = final: prev: {

    intel-media-sdk = prev.intel-media-sdk.overrideAttrs (old: {
      stdenv = prev.gcc13Stdenv;
      doCheck = false;
      cmakeFlags = (old.cmakeFlags or []) ++ [
        "-DBUILD_TESTS=OFF"
        "-DBUILD_SAMPLES=OFF"
      ];
    });

  };
}
