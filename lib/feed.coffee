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
