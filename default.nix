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
    # This fork is actively maintained compared to upstream.
    beam-mysql = pkgs.fetchFromGitHub {
      owner = "juspay";
      repo = "beam-mysql";
      rev = "5d17599e02f30c220b679439ee0c1025e3086250";
      sha256 = "sha256:09n42cg99cn3kj00ns1c3ds690w0y59rlliyp32pqd6gbcqq7bxr";
    };
  };
  hoogle = (compiler.override {
    overrides = self: super: with pkgs.haskell.lib; {
      ghc = super.ghc // { withPackages = super.ghc.withHoogle; };
      ghcWithPackages = self.ghc.withPackages;
      
      # Beam is broken in nixpkgs; https://github.com/NixOS/nixpkgs/issues/83380
      beam-core = dontCheck (self.callCabal2nix "beam-core" (src.beam + /beam-core) {});
      beam-migrate = dontCheck (self.callCabal2nix "beam-migrate" (src.beam + /beam-migrate) {});
      beam-postgres = dontCheck (self.callCabal2nix "beam-postgres" (src.beam + /beam-postgres) {});
      beam-sqlite = dontCheck (self.callCabal2nix "beam-sqlite" (src.beam + /beam-sqlite) {});
      beam-mysql = dontCheck (self.callCabal2nix "beam-sqlite" src.beam-mysql {});

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
  }).ghcWithPackages (p: with p; [
    beam-core 
    beam-postgres
    beam-mysql
    beam-migrate
    streamly
    text
    aeson
    warp
    http-client 
    lens
    semigroups
    monad-logger
    optparse-applicative
    profunctors
    bifunctors
    exceptions
    file-embed
    mtl
    tagged
    containers
    shower
  ]);
in 
  pkgs.writeShellScriptBin "hoogleverse" "${hoogle}/bin/hoogle server --local $*"
