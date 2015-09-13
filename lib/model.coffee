{ flatten } = require('sdk/util/array');

class Model
  constructor : (@sources, @filters) ->
    @feeds = flatten(source.getFeeds() for source in @sources)
    feed.on("updated", @onFeedUpdated) for feed in @feeds
    @requestUpdate()

  onFeedUpdated : (feed) =>
    for item in feed.items
      console.log(item.link)
    # TODO

  requestUpdate : =>
    feed.requestUpdate() for feed in @feeds

exports.Model = Model
