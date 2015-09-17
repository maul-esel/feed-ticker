{ XPathResult } = require('lib/markup')
{ FeedItem } = require('lib/feed_item')

###
# Parses a XML DOMDocument into FeedItem instances
interface Parser
  # Parses the given XML document
  #
  # @param feed [String] The unique ID of the feed the item belongs to
  # @param doc [Document] The document to parse
  #
  # @return [Array<FeedItem>] The items contained in the feed
  parse : (feed, doc)
###

nsResolver = (prefix) ->
  switch prefix
    when 'atom' then AtomParser.NS_ATOM

getString = (context, xpath) ->
  context.ownerDocument
    .evaluate(xpath, context, nsResolver, XPathResult.STRING_TYPE, null)
    .stringValue

# Parses a XML DOMDocument using the appropriate parser
#
# @param doc [Document] The document to parse
#
# @return [Array<FeedItem>] The items contained in the document
parse = (feed, doc) ->
  if doc.documentElement.tagName == 'rss'
    new RssParser().parse(feed, doc)
  else if doc.documentElement.namespaceURI == AtomParser.NS_ATOM
    new AtomParser().parse(feed, doc)
  else
    throw 'unsupported document type'

# Implements a parser for RSS documents
class RssParser # implements Parser
  parse : (feed, doc) =>
    entries = doc.evaluate('/rss/channel/item', doc, null, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(feed,
        title   : getString(entry, 'title/text()')
        link    : getString(entry, 'link/text()')
        id      : getString(entry, 'guid/text()')
        date    : getString(entry, 'pubDate/text()') # TODO: parse
        summary : getString(entry, 'description/text()')
      )

# Implements a parser for Atom feeds
class AtomParser # implements Parser
  @NS_ATOM = 'http://www.w3.org/2005/Atom'

  parse: (feed, doc) =>
    link_rels = ['not(@rel)', '@rel="alternate"', '@rel="self"']
    entries = doc.evaluate('/atom:feed/atom:entry', doc, nsResolver, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(feed,
        title   : getString(entry, 'atom:title/text()')
        link    : (link for rel in link_rels when (link = getString(entry, "atom:link[#{rel}]/@href")) != '')[0]
        id      : getString(entry, 'atom:id/text()')
        date    : getString(entry, 'atom:updated/text()') # TODO: parse
        summary : getString(entry, 'atom:summary/text()')
      )

exports.parse = parse
exports.RssParser = RssParser
exports.AtomParser = AtomParser
