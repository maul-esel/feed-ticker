###
# Filters feed items before display
interface Filter
  # Determines if a given item is accepted or not
  #
  # @param [FeedItem] item The item to check
  #
  # @return [Promise] A promise that is resolved with true if the item is
  # accepted, or false if it is rejected.
  isAccepted : (item)
###
