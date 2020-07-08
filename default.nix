let 
  nixpkgsRev = "4855aa62fa13";
  pkgs = import (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "sha256:17sk264qw397zzw12x11ry5vj9qidgbmjsyj544ysg857b4qq9sj";
    }) { };
in 
  pkgs.haskellPackages.developPackage {
    root = ./.;
    overrides = self: super: with pkgs.haskell.lib; {
      ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
      ghcWithPackages = self.ghc.withPackages;
    };
    modifier = drv:
      pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages;
        [ cabal-install
          ghcid
        ]);
  }
