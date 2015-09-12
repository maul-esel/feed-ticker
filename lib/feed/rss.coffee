{ RemoteXmlFeed } = require("lib/feed/remote_xml")
{ FeedItem } = require("lib/feed_item")

# Represents a RSS feed
class RssFeed extends RemoteXmlFeed
  # Creates a new instance of this class
  #
  # @param [String] url The URL of the feed
  constructor : (url) ->
    super(url, "application/rss+xml")

  handleDocument : (doc) =>
    entries = @getXml("/rss/channel/item")
    while (entry = entries.iterateNext()) != null
      new FeedItem({
        title : @getString("title/text()", entry),
        link : @getString("link/text()", entry),
        id : @getString("guid/text()", entry),
        date : @getString("pubDate/text()", entry), # TODO: parse
        summary : @getString("description/text()", entry)
      })

exports.RssFeed = RssFeed
