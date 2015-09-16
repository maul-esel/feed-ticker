{ Cc, Ci } = require('chrome')

exports.XPathResult =
  ANY_TYPE:                     Ci.nsIDOMXPathResult.ANY_TYPE
  NUMBER_TYPE:                  Ci.nsIDOMXPathResult.NUMBER_TYPE
  STRING_TYPE:                  Ci.nsIDOMXPathResult.STRING_TYPE
  BOOLEAN_TYPE:                 Ci.nsIDOMXPathResult.BOOLEAN_TYPE
  UNORDERED_NODE_ITERATOR_TYPE: Ci.nsIDOMXPathResult.UNORDERED_NODE_ITERATOR_TYPE
  ORDERED_NODE_ITERATOR_TYPE:   Ci.nsIDOMXPathResult.ORDERED_NODE_ITERATOR_TYPE
  UNORDERED_NODE_SNAPSHOT_TYPE: Ci.nsIDOMXPathResult.UNORDERED_NODE_SNAPSHOT_TYPE
  ORDERED_NODE_SNAPSHOT_TYPE:   Ci.nsIDOMXPathResult.ORDERED_NODE_SNAPSHOT_TYPE
  ANY_UNORDERED_NODE_TYPE:      Ci.nsIDOMXPathResult.ANY_UNORDERED_NODE_TYPE
  FIRST_ORDERED_NODE_TYPE:      Ci.nsIDOMXPathResult.FIRST_ORDERED_NODE_TYPE

exports.parse = (src, mime = 'application/xml') ->
  new Cc['@mozilla.org/xmlextras/domparser;1'](Ci.nsIDOMParser)
    .parseFromString(src, mime)
