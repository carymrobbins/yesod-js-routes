{-# LANGUAGE QuasiQuotes #-}
import Data.Text (unpack)
import System.Exit
import System.Process
import Test.HUnit ((@?=))
import Test.Hspec
import Yesod.Core
import Yesod.Routes.JavaScript

main :: IO ()
main = hspec $ do
    describe "JavaScript" $ it "executes successfully" $ exec "console.log(1+1)" === "2"
    describe "JavaScript routes generation" $ do
        let js = buildJSRoutes [parseRoutesNoCheck|
                    /           HomeR   GET
                    /foo/#Int   FooR    GET POST PUT DELETE
                 |]
            run x = exec $ unpack js ++ "console.log(" ++ x ++ ")"
        it "creates a jsRoutes variable" $ run "jsRoutes instanceof Object" === "true"
        it "creates a working get function" $ run "jsRoutes.HomeR.get()" === "{ method: 'get', url: '/' }"
        it "handles arguments" $ run "jsRoutes.FooR.put(1)" === "{ method: 'put', url: '/foo/1/' }"

(===) :: (Show a, Eq a) => IO a -> a -> IO ()
mx === y = do
    x <- mx
    x @?= y

nodePath :: String
nodePath = "node"

-- TODO: Run an interactive process to avoid spawning node multiple times.
exec :: String -> IO String
exec js = do
    (code, stdout, stderr) <- readProcessWithExitCode nodePath [] js
    case code of
        ExitSuccess -> return $ take (length stdout - 1) stdout
        _ -> putStrLn stderr >> error ("Failed to execute JavaScript:\n\n" ++ js)
