{-# LANGUAGE OverloadedStrings, Arrows #-}
module Main where

import Prelude hiding (id)
import Control.Category (id)
import Control.Monad (forM_)
import Control.Arrow (arr, (>>>), (***), second)
import Data.Monoid (mempty, mconcat)
import qualified Data.Map as M

import Hakyll

-- | Entry point
--
main :: IO ()
main = hakyllWith config $ do

    -- Copy images
    match "images/**" $ do
        route idRoute
        compile copyFileCompiler

{-
    match "favicon.ico" $ do
        route   idRoute
        compile copyFileCompiler
-}

    -- Copy JavaScript
    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- Copy Third Party libs
    match "lib/**/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- Copy misc resources
    match "resources/*" $ do
        route   idRoute
        compile copyFileCompiler

    -- Compress CSS
    match "css/*" $ do
        route idRoute
        compile compressCssCompiler

    -- Render each and every post
    match "posts/*" $ do
        route   $ setExtension ".html"
        compile $ pageCompiler
            >>> arr (renderDateField "date" "%B %e, %Y" "Date unknown")
            >>> renderTagsField "prettytags" (fromCapture "tags/*")
            >>> applyTemplateCompiler "templates/post.html"
            >>> applyTemplateCompiler "templates/default.html"

    -- Post list
    match "posts.html" $ route idRoute
    create "posts.html" $ constA mempty
        >>> arr (setField "title" "Posts")
        >>> setFieldPageList recentFirst
                "templates/postitem.html" "posts" "posts/*"
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"

    -- Index
    match "index.html" $ route idRoute
    create "index.html" $ constA mempty
        >>> arr (setField "title" "Home")
        >>> requireA "tags" (setFieldA "tagcloud" (renderTagCloud'))
        >>> setFieldPageList (take 3 . recentFirst)
                "templates/postitem.html" "posts" "posts/*"
        >>> applyTemplateCompiler "templates/index.html"
        >>> applyTemplateCompiler "templates/default.html"
        >>> relativizeUrlsCompiler

    -- Tags
    create "tags" $
        requireAll "posts/*" (\_ ps -> readTags ps :: Tags String)

    -- Add a tag list compiler for every tag
    match "tags/*" $ route $ setExtension ".html"
    metaCompile $ require_ "tags"
        >>> arr tagsMap
        >>> arr (map (\(t, p) -> (tagIdentifier t, makeTagList t p)))

    -- Read templates
    match "templates/*" $ compile templateCompiler

    -- Render some static pages
    forM_ ["author.markdown"] $ \p ->
        match p $ do
            route   $ setExtension ".html"
            compile $ pageCompiler
                >>> applyTemplateCompiler "templates/timeline.html"
                >>> relativizeUrlsCompiler

{-
    forM_ ["exhibits/approved_drugs.markdown"] $ \p ->
        match p $ do
            route   $ setExtension ".html"
            compile $ pageCompiler
                >>> applyTemplateCompiler "templates/exhibit.html"
                >>> relativizeUrlsCompiler
-}

    -- Render RSS feed
    match "rss.xml" $ route idRoute
    create "rss.xml" $ requireAll_ "posts/*" >>> renderRss myFeedConfiguration

    -- End
    return ()
  where
    renderTagCloud' :: Compiler (Tags String) String
    renderTagCloud' = renderTagCloud tagIdentifier 100 120

    tagIdentifier :: String -> Identifier (Page String)
    tagIdentifier = fromCapture "tags/*"

makeTagList :: String
            -> [Page String]
            -> Compiler () (Page String)
makeTagList tag posts =
    constA posts
        >>> pageListCompiler recentFirst "templates/postitem.html"
        >>> arr (copyBodyToField "posts" . fromBody)
        >>> arr (setField "title" ("Posts tagged " ++ tag))
        >>> applyTemplateCompiler "templates/posts.html"
        >>> applyTemplateCompiler "templates/default.html"

config :: HakyllConfiguration
config = defaultHakyllConfiguration
    {-{ deployCommand = "rsync --checksum -ave 'ssh -p 2222' \
                      \_site/* jaspervdj@jaspervdj.be:jaspervdj.be"
    }-}

myFeedConfiguration = FeedConfiguration
    { feedTitle       = "Pharmash RSS feed."
    , feedDescription = "Pharmash the Blog - RSS feed"
    , feedAuthorName  = "Orion Jankowski"
    , feedRoot        = "http://www.pharmash.com"
    }

