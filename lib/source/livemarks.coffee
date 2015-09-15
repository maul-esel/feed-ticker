{ Cu } = require('chrome')
{ RssFeed } = require('lib/feed/rss')

Cu.import('resource://gre/modules/PlacesUtils.jsm')

class LivemarkSource # implements Source
  getFeeds : () =>
    new RssFeed(feed.annotationValue) for feed in PlacesUtils.annotations.getAnnotationsWithName('livemark/feedURI')

exports.LivemarkSource = LivemarkSource
