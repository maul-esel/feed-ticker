{ Cu } = require('chrome')
{ AtomRssFeed } = require('lib/feed')

Cu.import('resource://gre/modules/PlacesUtils.jsm')

class LivemarkSource # implements Source
  getFeeds : () =>
    new AtomRssFeed(feed.annotationValue) for feed in PlacesUtils.annotations.getAnnotationsWithName(PlacesUtils.LMANNO_FEEDURI)

exports.LivemarkSource = LivemarkSource
