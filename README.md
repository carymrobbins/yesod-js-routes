yesod-js-routes
===============

This library makes it simple to generate JavaScript routes for Yesod.

In your `Foundation` module you will need to make your `App` an instance of `JSRoutable`.  This must come
after `parseRoutesFile` since parsing the routes generates `resourcesApp` -

```haskell
import Yesod.Routes.JavaScript
...
mkYesodData "App" $(parseRoutesFile "config/routes")

instance JSRoutable App where
    jsRoutes = jsRoutesBuilder resourcesApp
```

You can then create a resource for it in your routes file -

```
/jsRoutes JSRoutesR GET
```

Be sure to `import Yesod.Routes.JavaScript` in your `Application` module as well so that `getJSRoutesR` will
be in scope.

You can even add your JavaScript routes to your default layout in `Foundation` -

```haskell
instance Yesod App where
    ...
    defaultLayout widget = do
        ...
        pc <- widgetToPageContent $ do
            addScript JSRoutesR
            ...
```

Now you will have a `jsRoutes` variable accessible from JavaScript that will contain your routes.  For example,
given the following routes file -

```
/               HomeR   GET POST
/rules          RulesR  GET POST
/rule/#RuleId   RuleR   PUT DELETE
```

The following JavaScript would be generated -

```javascript
var jsRoutes = {};
jsRoutes.HomeR = {
    get: function() { return {method: "get", url: "/"}; },
    post: function() { return {method: "post", url: "/"}; }
};
jsRoutes.RulesR = {
    get: function() { return {method: "get", url: "/rules/"}; },
    post: function() { return {method: "post", url: "/rules/"}; }
};
jsRoutes.RuleR = {
    put: function() { return {method: "put", url: "/rule/" + arguments[0] + "/"}; },
    delete: function() { return {method: "delete", url: "/rule/" + arguments[0] + "/"}; }
};
jsRoutes.ForecastR = {
    post: function() { return {method: "post", url: "/forecast/"}; }
};
```
