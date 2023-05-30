# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

  inputs.sqlite3pp = {
    type  = "github";
    owner = "iwongu";
    repo  = "sqlite3pp";
    ref   = "v1.0.8";
    flake = false;
  };


# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, sqlite3pp, ... }: let

# ---------------------------------------------------------------------------- #

    eachDefaultSystemMap = let
      defaultSystems = [
        "x86_64-linux"  "aarch64-linux"  "i686-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
    in fn: let
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc defaultSystems );


# ---------------------------------------------------------------------------- #

    pkg-fun = { system, bash, coreutils, ... }: let
      pname   = "sqlite3pp";
      version = "1.0.8";
    in ( derivation {
      name = pname + "-" + version;
      inherit pname version system;
      src     = sqlite3pp.outPath;
      builder = bash.outPath + "/bin/bash";
      PATH    = coreutils.outPath + "/bin";
      args    = ["-eu" "-o" "pipefail" "-c" ''
        mkdir -p "$out";
        cp -r -- "$src/headeronly_src" "$out/include";
      ''];
    } ) // { meta = {}; };


# ---------------------------------------------------------------------------- #

    overlays.default   = overlays.sqlite3pp;
    overlays.sqlite3pp = final: prev: {
      sqlite3pp = final.callPackage pkg-fun {};
    };


# ---------------------------------------------------------------------------- #

    packages = eachDefaultSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.sqlite3pp;
    in {
      inherit (pkgsFor) sqlite3pp;
      default = pkgsFor.sqlite3pp;
    } );


# ---------------------------------------------------------------------------- #

  in {

# ---------------------------------------------------------------------------- #

    inherit overlays packages;
    legacyPackages = packages;


# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
