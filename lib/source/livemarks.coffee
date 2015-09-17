{ Cu } = require('chrome')
{ RemoteXmlFeed } = require('lib/feed')

Cu.import('resource://gre/modules/PlacesUtils.jsm')

class LivemarkSource # implements Source
  getFeeds : () =>
    new RemoteXmlFeed(feed.annotationValue) for feed in PlacesUtils.annotations.getAnnotationsWithName('livemark/feedURI')

exports.LivemarkSource = LivemarkSource
