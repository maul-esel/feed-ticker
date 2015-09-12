{ EventTarget } = require("sdk/event/target")
{ emit } = require('sdk/event/core')

# Represents a feed of items to display
# @abstract
class Feed extends EventTarget
  # The list of currently known items
  items : []

  # Updates the feed content
  # @abstract
  requestUpdate : =>

  # @event updated Raised when the feed content has been updated

  # Notifies listeners of a change in feed content
  # @private
  onUpdated : =>
    emit(this, "updated", this)

exports.Feed = Feed
