{ browserWindows } = require('sdk/windows')
{ viewFor } = require('sdk/view/core')

# Base class for everything concerning context menus
# @abstract
class MenuObjectBase
  # Namespace URI for XUL
  # @private
  @NS_XUL : 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul'

  # Creates a XUL element
  #
  # @param [Document] doc The document where the element should be created
  # @param [String] tag The tag name (no namespace prefix)
  # @param [Object] attributes An object with attributes for the element
  # @param [Element[]] children Child elements to add to the created element
  #
  # @return [Element] the newly created DOM element
  createElement : (doc, tag, attributes = {}, children = []) =>
    element = doc.createElementNS(@constructor.NS_XUL, tag)
    element.setAttribute(key, value) for key, value of attributes
    element.appendChild(child) for child in children
    element

  # Sets supplied options on the instance
  #
  # @param [Object] available An object with supported options and their default values
  # @param [Object] actual An object containing the actually supplied options
  applyOptions : (available, actual) =>
    for option, defaultValue of available
      @[option] = if actual.hasOwnProperty(option) then actual[option] else defaultValue

  # Builds the DOM for the menu object
  # @abstract
  #
  # @param [Document] doc The DOM document where the object should be built
  #
  # @return [Element] The DOM element representing the menu object
  build : (doc) =>

# Base class for menus
# @abstract
class MenuBase extends MenuObjectBase
  # The items contained in the menu
  items : []

  # Appends an item to the menu
  #
  # @param [MenuItem,SubMenu,MenuSeparator] item The item to append
  append : (item) =>
    @items.push(item)

  # Inserts an item into the menu
  #
  # @param [Integer] index The index where the item should be inserted
  # @param [MenuItem,SubMenu,MenuSeparator] item The item to insert
  insert : (index, item) =>
    @items[index...index] = [item]

  build : (doc) =>
    @createElement(doc, 'menupopup', {}, item.build(doc) for item in @items)

# Represents a simple item in a menu
class MenuItem extends MenuObjectBase
  @available_options : { disabled: false, checked: false, image: '', action: undefined }

  # Creates a new menu item
  #
  # @param [String] label The display label for the item
  # @param [Object] options Further options for the item
  #
  # @option options [Boolean] disabled True to disable the item
  # @option options [Boolean] checked True to display a check mark next to the item
  # @option options [String] image The URI of an icon to display next to the item
  # @option options [Function] action A callback to be called when the item is selected
  constructor : (@label, options = {}) ->
    @applyOptions(@constructor.available_options, options)

  build : (doc) =>
    element = @createElement(doc, 'menuitem', { label: @label, disabled: @disabled, checked: @checked, image: @image })
    element.addEventListener('command', @action) if @action?
    element

# Represents a menu item containing a sub menu
class SubMenu extends MenuBase
  # Creates a new sub menu
  #
  # @param [String] label The sub menu's display label
  # @param [Array] items The items the sub menu will contain
  constructor : (@label, @items = []) ->

  build : (doc) =>
    @createElement(doc, 'menu', { label: @label }, [ super(doc) ])

# Represents a item separator element
class MenuSeparator extends MenuObjectBase
  build : (doc) =>
    @createElement(doc, 'menuseparator')

# Represents a context menu for firefox UI elements
class ContextMenu extends MenuBase
  # A menu item representing a separator
  @Separator : new MenuSeparator

  @instance_counter : 0

  # Creates a new context menu
  #
  # @param [Array] items The items the menu will contain
  constructor : (@items = []) ->
    @id = 'feedticker_context_menu_custom__instance' + @constructor.instance_counter++

  # Attaches the context menu to a firefox UI element
  #
  # @param [String] id The XUL document ID of the element
  # @param [nsIDOMWindow] window The window where the element resides. Omit or set
  #   to null to attach the menu to all items with the given ID in all currently opened browser windows.
  # @param [Boolean] forceUpdate Whether or not the menu should be re-created in windows
  #   where it already exists. Set to true if you made change to the menu or its items
  #   and want them to take effect.
  attach : (id, window = null, forceUpdate = false) =>
    if window?
      @create(window.document, forceUpdate)
      window.document.getElementById(id)?.setAttribute('context', @id)
    else
      @attach(id, viewFor(win)) for win in browserWindows

  # Creates the menu's XUL DOM structure
  # @private
  #
  # @param [Document] doc The XUL document where the menu should be created
  # @param [Boolean] forceUpdate Whether or not the menu should be re-created if it already exists.
  create : (doc, forceUpdate = false) =>
    oldMenu = doc.getElementById(@id)
    if forceUpdate || !oldMenu?
      [menu, mainPopupSet] = [@build(doc), doc.getElementById('mainPopupSet')]
      if oldMenu?
        mainPopupSet.replaceChild(menu, oldMenu)
      else
        mainPopupSet.appendChild(menu)

  build : (doc) =>
    element = super(doc)
    element.setAttribute('id', @id)
    element

exports.ContextMenu = ContextMenu
exports.MenuItem = MenuItem
exports.SubMenu = SubMenu
