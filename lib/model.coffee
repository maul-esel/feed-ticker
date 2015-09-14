{ flatten } = require('sdk/util/array')
{ all } = require("sdk/core/promise")
{ identity } = require("sdk/lang/functional")
{ setInterval } = require("sdk/timers")
preferences = require("sdk/simple-prefs").prefs

{ ViewManager } = require("lib/view_manager")

class Model
  constructor : (@sources, @filters) ->
    @viewManager = new ViewManager
    @update()
    setInterval(@update, preferences.updateTimerInterval * 1000)

  update : =>
    feeds = flatten(source.getFeeds() for source in @sources)
    @viewManager.clear()
    all(
      feed.update().then((=> @filterItems(feed)), (=> @filterItems(feed))) for feed in feeds
    ).then(=> @viewManager.update())

  filterItems : (feed) =>
    all(@filter(item) for item in feed.items)

  filter : (item) =>
    all(filter.isAccepted(item) for filter in @filters)
    .then( (results) => @viewManager.displayItem(item) if results.every(identity) )

exports.Model = Model
