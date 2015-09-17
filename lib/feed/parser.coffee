{ XPathResult } = require('lib/markup')
{ FeedItem } = require('lib/feed_item')

###
# Parses a XML DOMDocument into FeedItem instances
interface Parser
  # Determines if this parser can handle the given XML document.
  # A complete model check is not necessary, just a quick check for the type of the document
  #
  # @param doc [Document] The document to evaluate
  #
  # @return [Boolean] True if the parser can parse the document, false otherwise
  canParse : (doc)

  # Parses the given XML document
  #
  # @param doc [Document] The document to parse
  #
  # @return [Array<FeedItem>] The items contained in the feed
  parse : (doc)
###

nsResolver = (prefix) ->
  switch prefix
    when 'atom' then AtomParser.NS_ATOM

getString = (context, xpath) ->
  context.ownerDocument
    .evaluate(xpath, context, nsResolver, XPathResult.STRING_TYPE, null)
    .stringValue

# Implements a parser for RSS documents
class RssParser # implements Parser
  canParse : (doc) =>
    doc.documentElement.tagName == 'rss'

  parse : (doc) =>
    entries = doc.evaluate('/rss/channel/item', doc, null, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(
        title   : getString(entry, 'title/text()')
        link    : getString(entry, 'link/text()')
        id      : getString(entry, 'guid/text()')
        date    : getString(entry, 'pubDate/text()') # TODO: parse
        summary : getString(entry, 'description/text()')
      )

# Implements a parser for Atom feeds
class AtomParser # implements Parser
  @NS_ATOM = 'http://www.w3.org/2005/Atom'

  canParse: (doc) =>
    doc.documentElement.namespaceURI == @constructor.NS_ATOM

  parse: (doc) =>
    link_rels = ['not(@rel)', '@rel="alternate"', '@rel="self"']
    entries = doc.evaluate('/atom:feed/atom:entry', doc, nsResolver, XPathResult.ANY_TYPE, null)
    while (entry = entries.iterateNext())?
      new FeedItem(
        title   : getString(entry, 'atom:title/text()')
        link    : (link for rel in link_rels when (link = getString(entry, "atom:link[#{rel}]/@href")) != '')[0]
        id      : getString(entry, 'atom:id/text()')
        date    : getString(entry, 'atom:updated/text()') # TODO: parse
        summary : getString(entry, 'atom:summary/text()')
      )

exports.RssParser = RssParser
exports.AtomParser = AtomParser
