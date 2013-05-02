{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Data.Monoid (mappend)
import System.FilePath (dropExtension, (</>))

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

  match "blog/*" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  --match "blog.html" $ route routeToDir
  create ["blog.html"] $ do
    route idRoute
    compile $ do
      let blogCtx =
            field "posts" (\_ -> postList recentFirst) `mappend`
            constField "title" "Archive"               `mappend`
            defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/blog_index.html" blogCtx
        >>= loadAndApplyTemplate "templates/default.html"  blogCtx
        >>= relativizeUrls

  match "templates/*" $
    compile templateCompiler


-- Utility functions -----------------------------------------------------------

-- Blatantly stolen from example Hakyll code
postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` defaultContext

-- Also blatantly ripped from example code
postList :: ([Item String] -> Compiler [Item String]) -> Compiler String
postList sortFilter = do
  posts   <- sortFilter =<< loadAll "blog/*"
  itemTpl <- loadBody "templates/post_item.html"
  list    <- applyTemplateList itemTpl postCtx posts
  return list

routeToDir :: Routes
routeToDir = customRoute fileToDir
  where
    fileToDir x = dropExtension (toFilePath x) </> "index.html"
