{ Cu } = require('chrome')
Cu.import('resource://gre/modules/PlacesUtils.jsm')

{ AtomRssFeed } = require('lib/feed')

###
# Provides a source of feeds
interface Source
  # Gets the @see Feed instances for this source
  #
  # @return [Feed[]] the feeds provided by this source
  getFeeds : ()
###

class LivemarkSource # implements Source
  getFeeds : () =>
    new AtomRssFeed(feed.annotationValue) for feed in PlacesUtils.annotations.getAnnotationsWithName(PlacesUtils.LMANNO_FEEDURI)

exports.LivemarkSource = LivemarkSource
