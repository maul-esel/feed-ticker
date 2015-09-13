curry = (fn, args...) ->
  -> fn.apply(this, args.concat(Array.slice(arguments)))

# Manages the frame content of the toolbar
class window.View
  # Current offset of moving ticker items
  offset : 0

  # Creates a new instance of the class
  #
  # @param [Element] container The container element where feed items are placed
  constructor : (@container) ->
    window.addEventListener('message', @onMessageReceived, false)
    @send('READY')
    @startMoving()
    @container.addEventListener("mouseenter", @stopMoving, true)
    @container.addEventListener("mouseleave", @startMoving, true)

  # Callback for communication with the @see ViewManager
  # @private
  onMessageReceived : (event) =>
    message = JSON.parse(event.data)
    switch message.command
      when 'REMOVE_ITEM' then @remove(message.data)
      when 'REPLACE_ITEMS' then @replaceItems(message.data)

  send : (command, data) =>
    window.parent.postMessage(JSON.stringify({
      command: command,
      data:data
    }), '*')

  # Helper method for replacing the feed items with new content from the manager
  # @private
  #
  # @param [FeedItem[]] items The new feed content
  replaceItems : (items) =>
    old_nodes = (@container.children.item(i) for i in [0...@container.children.length])

    for item in items
      index = old_nodes.findIndex((node) => node.getAttribute('data-ticker-id') == item.id)
      if index == -1
        entry = @createEntry(item)
        entry.addEventListener("click", curry(@onItemClicked, item))
        @container.appendChild(entry) # TODO: order
      else
        @updateNode(old_nodes[index], item)
        old_nodes[index..index] = [] # remove from old nodes

    node.remove() for node in old_nodes

  onItemClicked : (item) =>
    @send('NOTIFY_CLICK', item)

  # Helper method to update a feed entry with new information
  # @private
  #
  # @param [Element] node The feed entry to update
  # @param [FeedItem] item The information to be represented by the node
  updateNode : (node, item) =>
    unless node.childNodes.item(1).wholeText == item.title
      node.replaceChild(document.createTextNode(item.title), node.childNodes.item(1))
    unless node.children.item(0).getAttribute("src") == item.faviconURL
      node.children.item(0).setAttribute("src", item.faviconURL)

  # Helper method for removing feed entries as requested by the manager
  # @private
  #
  # @param [FeedItem] item The item whose entry should be removed
  remove : (item) =>
    document.querySelector(".ticker-item[data-ticker-id='#{item.id}']")?.remove()

  # Helper method to create a feed entry for a new item
  # @private
  #
  # @param [FeedItem] item The item whose information should be included in the entry
  #
  # @return [Element] The DOM element representing the item
  createEntry : (item) =>
    @buildHtml({
      type: 'button',
      classes: ['ticker-item'],
      attr : { type: 'button', 'data-ticker-id': item.id },
      children: [
        {
          type: 'img',
          attr: { src: item.faviconURL, alt: "" }
        },
        item.title
      ]
    })

  # Helper method to create HTML DOM elements from JSON data
  # @private
  #
  # @param [Object,String] The data to be converted
  #
  # @return [Node] The DOM node representing the data
  buildHtml : (data) =>
    if typeof(data) == "object"
      element = document.createElement(data.type)
      element.classList.add(cls) for cls in data.classes ? []
      element.setAttribute(attr, val) for attr, val of data.attr ? {}
      element.appendChild(@buildHtml(child)) for child in data.children ? []
      element
    else
      document.createTextNode(data)

  startMoving : =>
    @moveTimer = setInterval(@move, 1000) unless @moveTimer?

  stopMoving : =>
    clearInterval(@moveTimer) if @moveTimer?
    @moveTimer = undefined

  # Callback to move ticker entries
  # @private
  move : =>
    @offset = (@offset + 25) % 1000;
    entries = document.querySelectorAll(".ticker-item")
    for i in [0...entries.length]
      entries.item(i).style.left = @offset + "px"

exports.View = View
