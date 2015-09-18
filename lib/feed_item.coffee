{ getFavicon } = require('sdk/places/favicon')
{ URL } = require('sdk/url')

###
Represents an item in a feed
###
class FeedItem
  constructor: (@feed, { @title, @link, @id, @date, @summary }) ->
    getFavicon(@link).then (url) => @faviconURL = url,
    =>
      url = new URL(@link)
      @faviconURL = "#{url.scheme}://#{url.host}/favicon.ico"

exports.FeedItem = FeedItem
