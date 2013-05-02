{-# LANGUAGE OverloadedStrings #-}
import Hakyll

main :: IO ()
main = hakyll $ do
  match "img/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route   idRoute
    compile compressCssCompiler

  match "*.txt" $ do
    route   idRoute
    compile copyFileCompiler

  match "index.html" $ do
    route idRoute
    compile $ getResourceBody
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

  match (fromList ["about.markdown"]) $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  match "templates/*" $
    compile templateCompiler
