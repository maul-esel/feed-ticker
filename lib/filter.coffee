###
# Filters feed items before display
interface Filter
  # Determines if a given item is accepted or not
  #
  # @param [FeedItem] item The item to check
  # @param [Function] accept Callback to be called if the item is accepted. Its only argument if the item.
  # @param [Function] reject Callback to be called upon rejection of the item. It takes the item and optionally a reason string as arguments.
  filter : (item, accept, reject)
###
