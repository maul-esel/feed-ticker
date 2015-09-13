{ flatten } = require('sdk/util/array');
Promise = require("sdk/core/promise")

{ ViewManager } = require("lib/view_manager")

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    feed.on("updated", @onFeedUpdated) for feed in @feeds
    @requestUpdate()
    @viewManager = new ViewManager

  onFeedUpdated : (feed) =>
    promises = (@filter(item) for item in feed.items)
    # Once all items have been filtered, update the views – even if some items were rejected.
    Promise.all(promises).then (=> @viewManager.update()), (=> @viewManager.update())

  requestUpdate : =>
    feed.requestUpdate() for feed in @feeds

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
