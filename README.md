# Hoogleverse

Run dedicated Hoogle server with a custom list of packages.

## Adding / removing Haskell packages

Modify the list at the end of default.nix. Then run `nix-build` to test.

## Running hoogle server

```sh
$(nix-build)/bin/hoogleverse -p 8080
```

