{ flatten } = require('sdk/util/array')
{ all } = require('sdk/core/promise')
{ identity, partial } = require('sdk/lang/functional')
{ setInterval } = require('sdk/timers')
preferences = require('sdk/simple-prefs').prefs
tabs = require('sdk/tabs')

{ ViewManager } = require('lib/view_manager')
history = require('lib/history')

class FeedTicker
  constructor : (@sources, @filters) ->
    @viewManager = (new ViewManager)
      .on('refresh', @update)
      .on('open', @onViewOpen)
      .on('mark_read', @onMarkRead)
    @update()
    setInterval(@update, preferences.updateTimerInterval * 1000)

  update : =>
    feeds = flatten(source.getFeeds() for source in @sources)
    @viewManager.clear()
    all(
      feed.update().then(partial(@filterItems, feed), partial(@filterItems, feed)) for feed in feeds
    ).then(=> @viewManager.update())

  filterItems : (feed) =>
    all(@filter(item) for item in feed.items)

  filter : (item) =>
    all(filter.isAccepted(item) for filter in @filters)
    .then( (results) => @viewManager.displayItem(item) if results.every(identity) )

  onViewOpen : (target) =>
    for item in @getItems(target)
      tabs.open(item.link)
      @viewManager.removeItem(item)

  onMarkRead : (target) =>
    for item in @getItems(target)
      history.markVisited(item.link)
      @viewManager.removeItem(item)

  getItems : (target) =>
    if target == null # i.e. all
      @viewManager.displayedItems[..] # create a copy so it can be looped through while modifying the viewManager
    else if typeof(target) == 'string' # feed ID
      (item for item in @viewManager.displayedItems when item.feed == target)
    else # FeedItem instance
      [target]

exports.FeedTicker = FeedTicker
