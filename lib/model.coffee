{ flatten } = require('sdk/util/array')
Promise = require("sdk/core/promise")

{ ViewManager } = require("lib/view_manager")

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    @viewManager = new ViewManager
    @update()

  update : =>
    @viewManager.clear()
    Promise.all(
      feed.update().then((=> @filterItems(feed)), (=> @filterItems(feed))) for feed in @feeds
    ).then(=> @viewManager.update())

  filterItems : (feed) =>
    Promise.all(@filter(item) for item in feed.items)

  filter : (item) =>
    # Ask every filter to check the item.
    # Pack it into a promise and let filters
    # resolve the promise upon acceptance,
    # or reject it.
    promises = for filter in @filters
      { promise, resolve, reject } = Promise.defer()
      filter.filter(item, resolve, reject)
      promise
    # Collect all promises and pack them.
    # Once all filters are done, display the item or not.
    Promise.all(promises).then (=> @display(item)), (=> @remove(item))

  display : (item) =>
    @viewManager.displayItem(item)

  remove : (item) =>
    @viewManager.removeItem(item)

exports.Model = Model
