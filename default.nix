let 
  nixpkgsRev = "571212eb839d";
  pkgs = import (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "sha256:0ncsh5rkjbcdaksngmn7apiq1qhm5z1z6xa1x70svxq91znibp4f";
    }) { };
in 
  pkgs.haskellPackages.developPackage {
    root = ./.;
    modifier = drv:
      pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages;
        [ cabal-install
          ghcid
        ]);
  }
