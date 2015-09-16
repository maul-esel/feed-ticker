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
