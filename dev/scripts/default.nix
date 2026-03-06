{ lib, pkgs }:

let
  dir = ./.;
  entries = lib.filterAttrs (name: _: name != "default.nix") (builtins.readDir dir);

  validateEntry =
    entry: kind:
    if kind == "regular" then
      lib.throwIfNot (lib.hasSuffix ".nix" entry) "Invalid file '${entry}': only .nix files are allowed"
        entry
    else if kind == "directory" then
      lib.throwIfNot (builtins.pathExists (
        dir + "/${entry}/default.nix"
      )) "Directory '${entry}' has no default.nix" entry
    else
      throw "Unsupported filesystem entry '${entry}' (${kind})";

  validateAttrset =
    entry:
    let
      attrset = import (dir + "/${entry}") { inherit lib pkgs; };
    in
    assert builtins.isAttrs attrset || throw "Import '${entry}' did not return an attrset";
    assert
      (builtins.hasAttr "name" attrset && builtins.isString attrset.name)
      || throw "Import '${entry}' missing string field 'name'";
    assert
      (builtins.hasAttr "description" attrset && builtins.isString attrset.description)
      || throw "Import '${entry}' missing string field 'description'";
    assert
      (builtins.hasAttr "package" attrset && lib.isDerivation attrset.package)
      || throw "Import '${entry}' missing derivation field 'package'";
    attrset;

  manifest = lib.mapAttrs (
    fileName: kind:
    let
      entry = validateEntry fileName kind;
      attrset = validateAttrset entry;
    in
    attrset
  ) entries;
in
lib.mapAttrs' (_: value: lib.nameValuePair value.name value.package) manifest
// {
  help = pkgs.writeShellScriptBin "help" ''
    {
      printf "%s\n" "Command|Description"
      printf "%s\n" "${
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (_: value: "${value.name}|${value.description}") manifest
        )
      }"
      printf "%s\n" "help|Display this help message"
    } | ${pkgs.gum}/bin/gum table \
      --separator "|" \
      --print \
      --border rounded \
      --border.foreground "#04B575"
  '';
}
