define ->
  class Router extends Backbone.Router
    routes:
        ""        : "project"
        ":node"   : "node"

  return new Router