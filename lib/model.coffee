{ flatten } = require('sdk/util/array');

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    for feed in @feeds
      feed.on("updated", @onFeedUpdated)
    @requestUpdate()

  onFeedUpdated : (feed) =>
    for item in feed.items
      console.log(item.link)
    # TODO

  requestUpdate : =>
    for feed in @feeds
      feed.requestUpdate()

exports.Model = Model
