{ Request } = require("sdk/request")
Promise = require("sdk/core/promise")
{ Cc, Ci } = require("chrome")

# A base class for feeds based on XML documents available on the web
# @abstract
class RemoteXmlFeed # implements Feed
  items : []

  # Exposes the XPathResult.ANY_TYPE constant to subclasses
  @RESULT_TYPE_ANY : Ci.nsIDOMXPathResult.ANY_TYPE

  # Exposes the XPathResult.STRING_TYPE constant to subclasses
  @RESULT_TYPE_STRING : Ci.nsIDOMXPathResult.STRING_TYPE

  # Creates a new instance of this class.
  #
  # @param [String] url The URL where the XML document can be found
  # @param [String] mime The MIME type to use when requesting the document
  constructor : (@url, @mime) ->

  update : =>
    { promise, resolve, reject } = Promise.defer()
    @current_request = Request({
      url: @url,
      headers: {
        Accept: @mime
      },
      onComplete: (response) => @onDocumentReceived(response, resolve, reject)
    })
    @current_request.get()
    promise

  # Callback for requests to the URL
  # @private
  onDocumentReceived : (response, resolve, reject) =>
    if 200 <= response.status < 300
      try
        @items = @handleDocument(@doc = @parseXml(response.text))
        resolve()
      catch error
        reject()
    else
      reject()

  # Helper method to parse XML
  # @private
  #
  # @param [String] src The XML source code
  #
  # @return [Document] A DOM document representing the XML
  parseXml : (src) =>
    new Cc["@mozilla.org/xmlextras/domparser;1"](Ci.nsIDOMParser)
      .parseFromString(src, "application/xml")

  # Helper method for subclasses to navigate the XML using xpath
  getXml : (xpath, context = null, nsResolver = null, resultType = null) =>
    @doc.evaluate(xpath, context ? @doc, nsResolver, resultType ? @constructor.RESULT_TYPE_ANY, null)

  # Helper method for subclasses to navigate the XML using xpath
  getString : (xpath, context = null, nsResolver = null) =>
    @getXml(xpath, context, nsResolver, @constructor.RESULT_TYPE_STRING).stringValue

  # Converts the loaded XML document into a list of items.
  # This method is called internally and must be implemented by subclasses.
  # @abstract
  #
  # @param [Document] doc The loaded XML content
  #
  # @return [FeedItem[]] The feed items retrieved from the XML document
  handleDocument : (doc) =>

exports.RemoteXmlFeed = RemoteXmlFeed
