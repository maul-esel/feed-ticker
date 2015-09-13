{ flatten } = require('sdk/util/array');
Promise = require("sdk/core/promise")

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    feed.on("updated", @onFeedUpdated) for feed in @feeds
    @requestUpdate()

  onFeedUpdated : (feed) =>
    @filter(item) for item in feed.items

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
    console.log("display:", item.link)

  remove : (item) =>
    console.log("remove:", item.link)

exports.Model = Model
