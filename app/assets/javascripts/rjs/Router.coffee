define ->
  class Router extends Backbone.Router
    routes:
        "/"        : "project"
        "/:node"   : "node"

    node: (node) =>
      console.log node

  return new Router