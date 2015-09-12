###
# Filters feed items before display
interface Filter
  # Determines if a given item is accepted or not
  #
  # @param [FeedItem] item
  #
  # @return [Boolean] true if the item should be displayed, false otherwise 
  isAccepted : (item)
###
