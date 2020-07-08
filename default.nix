let 
  # Get the newest rev from https://status.nixos.org/ to update nixpkgs
  nixpkgsRev = "4855aa62fa13";
  pkgs = import (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz";
      sha256 = "sha256:17sk264qw397zzw12x11ry5vj9qidgbmjsyj544ysg857b4qq9sj";
    }) { };
  compiler = pkgs.haskellPackages;

  # Sources
  src = {
    beam = pkgs.fetchFromGitHub {
      owner = "haskell-beam";
      repo = "beam";
      rev = "c858846e322ad28fe53fb6c56006bb1a52b20683";
      sha256 = "sha256:1xffrdbfs2d61qwlchqj4pc5yczkipbghhr5566p2bn1163mmyqw";
    };
    beam-mysql = pkgs.fetchFromGitHub {
      owner = "tathougies";
      repo = "beam-mysql";
      rev = "2c561b486acf80c7847f48667f1a7d9222f2b35a";
      sha256 = "sha256:1b9rnd0dxc33dk0c71kiivn69lzr3gk5d01p98d5lmi7yvsqsd0m";
    };
  };
in 
  compiler.developPackage {
    root = ./.;
    source-overrides = {
      # Beam is broken in nixpkgs; https://github.com/NixOS/nixpkgs/issues/83380
      beam-core = src.beam + /beam-core;
      beam-migrate = src.beam + /beam-migrate;
      beam-sqlite = src.beam + /beam-sqlite;
      beam-postgres = src.beam + /beam-postgres;
      beam-mysql = src.beam-mysql;
    };
    overrides = self: super: with pkgs.haskell.lib; {
      ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
      ghcWithPackages = self.ghc.withPackages;
      
      beam-core = dontCheck super.beam-core;
      beam-migrate = dontCheck super.beam-migrate;
      beam-sqlite = dontCheck super.beam-sqlite;
      beam-postgres = dontCheck super.beam-postgres;
      beam-mysql = dontCheck super.beam-mysql;

      # Beam requires these
      haskell-src-exts = self.callHackage "haskell-src-exts" "1.21.1" {};
      haskell-src-meta = dontCheck super.haskell-src-meta;
      hashable = doJailbreak (self.callHackage "hashable" "1.2.7.0" {});
      # Override rebase's hashablar version lock
      rebase = doJailbreak super.rebase;

      # Latest hoogle requires a version of haskell-src-exts that conflicts with beam.
      # Pick the version that plays along nice with beam's requirement.
      hoogle = self.callHackage "hoogle" "5.0.17.11" {};
    };
    modifier = drv:
      pkgs.haskell.lib.addBuildTools drv (with pkgs.haskellPackages;
        [ cabal-install
        ]);
  }
