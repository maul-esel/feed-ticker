{ Request } = require('sdk/request')
Promise = require('sdk/core/promise')

xml = require('lib/markup')
{ RssParser, AtomParser } = require('lib/parser')

###
# Represents a feed of items to display
interface Feed
  # The list of currently known items
  items : []

  # Updates the feed content
  #
  # @return [Promise] A promise that is resolved once the update is complete, or rejected in case of error.
  update : ()
###

# A class for feeds based on XML documents available on the web
class RemoteXmlFeed # implements Feed
  items : []

  parsers : [new RssParser, new AtomParser]

  # Creates a new instance of this class.
  #
  # @param [String] url The URL where the XML document can be found
  constructor : (@url) ->

  update : =>
    { promise, resolve, reject } = Promise.defer()
    Request(
      url: @url
      onComplete: (response) =>
        try
          @onDocumentReceived(response)
          resolve()
        catch error then reject(error)
    ).get()
    promise

  # Callback for requests to the URL
  # @private
  onDocumentReceived : (response) =>
    throw "request failed" unless 200 <= response.status < 300
    doc = xml.parse(response.text)
    @items = @parsers.find((p) => p.canParse(doc)).parse(doc)

exports.RemoteXmlFeed = RemoteXmlFeed
