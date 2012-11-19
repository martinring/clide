define ->
  class Router extends Backbone.Router
    routes:
        "/martinring/test/"        : "project"
        "/martinring/test/:node"   : "node"

  return new Router