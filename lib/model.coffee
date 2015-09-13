{ flatten } = require('sdk/util/array')
{ all } = require("sdk/core/promise")
{ identity } = require("sdk/lang/functional")

{ ViewManager } = require("lib/view_manager")

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    @viewManager = new ViewManager
    @update()

  update : =>
    @viewManager.clear()
    all(
      feed.update().then((=> @filterItems(feed)), (=> @filterItems(feed))) for feed in @feeds
    ).then(=> @viewManager.update())

  filterItems : (feed) =>
    all(@filter(item) for item in feed.items)

  filter : (item) =>
    all(filter.isAccepted(item) for filter in @filters)
    .then( (results) => @viewManager.displayItem(item) if results.every(identity) )

exports.Model = Model
