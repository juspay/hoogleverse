# Haskell Playground

A very easy to get started environment for playing with Haskell, based on Nix.

## Getting Started

First, [install Nix](https://nixos.org/nix/), and then directly run the app in "auto-recompilation" mode (thanks to `ghcid`):

```sh 
nix-shell --run "ghcid -T :main"
```

Now try changing `Main.hs` and it should reload the app automatically. Compile errors if any will be displayed by this command.

## Interactive REPL

Launch GHCi,

```sh
nix-shell --run "cabal repl"
```

Inside the repl, import your Main.hs module:

```haskell
λ> import Main
```

Run the `main` function:

```haskell
λ> main
"UserName {fullName = \"John\", lastName = \"Doe\"}\n"
λ>
```

Use `:r` to reload the module. You can also directly play with the data types; for example:

```haskell
λ> let user = UserName "srid" "r"
λ> user
UserName {fullName = "srid", lastName = "r"}
λ> fullName user
"srid"
λ> length (fullName user)
4
λ>
```

## Adding libraries

Add the name of your library (from [Hackage](http://hackage.haskell.org/)) to the `haskell-playground.cabal` file under the `build-depends` section, and then restart the above commands. 

## Further reading

* [Nix recipes for Haskellers](https://www.srid.ca/1948201.html)
