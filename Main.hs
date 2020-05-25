{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Shower (shower)

data UserName = UserName
  { fullName :: String,
    lastName :: String
  }
  deriving (Eq, Show)

main :: IO ()
main = do
  let me = UserName "John" "Doe"
  print $ shower me
