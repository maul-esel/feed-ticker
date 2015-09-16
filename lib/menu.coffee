{ browserWindows } = require('sdk/windows')
{ viewFor } = require('sdk/view/core')
{ identify } = require('sdk/ui/id')

# Base class for everything concerning menus
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
    element = @createElement(doc, 'menupopup', {}, item.build(doc) for item in @items)
    element.addEventListener('popuphiding', @onHide) if @onHide?
    element

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

# Represents an item separator element
class MenuSeparator extends MenuObjectBase
  build : (doc) =>
    @createElement(doc, 'menuseparator')

# Represents a menu for firefox UI elements
class Menu extends MenuBase
  # A menu item representing a separator
  @Separator : new MenuSeparator

  @instance_counter : 0

  contextMenuTargets: []
  menuButtonTargets: []

  # Creates a new context menu
  #
  # @param [Array] items The items the menu will contain
  constructor : (@items = [], options = {}) ->
    @id = 'feedticker_custom_menu__instance' + @constructor.instance_counter++
    browserWindows.on('open', @onNewWindow)
    { @onHide } = options
    [@contextMenuTargets, @menuButtonTargets] = [[], []] # needed, otherwise instances share them

  # Sets this menu as context menu on a given target
  #
  # @param [String,Object] target The target for the context menu, either as XUL ID (String)
  #   or as an object on which @see identify() returns the XUL id.
  contextMenu : (target) =>
    target = identify(target) unless typeof(target) == 'string'
    @contextMenuTargets.push(target)
    @setContextMenu(viewFor(window).document, target) for window in browserWindows

  # Sets this menu as button menu on a given button
  #
  # @param [String,Object] target The button to use, or its XUL ID
  # @param [Boolean] menuOnly True to create a menu-only button, false for a button
  #   that has a separate command action
  menuButton : (target, menuOnly = true) =>
    target = identify(target) unless typeof(target) == 'string'
    @menuButtonTargets.push([target, menuOnly])
    @setButtonMenu(viewFor(window).document, target, menuOnly) for window in browserWindows

  # Updates the menu everywhere it is used. Call this method in order for changes
  # made to the menu or its items to take effect.
  update : =>
    for window in browserWindows
      doc = viewFor(window).document
      if @contextMenuTargets.length > 0
        doc.getElementById(@id + '__context').remove()
        @createContextMenu(doc)

      for [target, menuOnly] in @menuButtonTargets
        suffix = '__button__' + target
        doc.getElementById(target)
          ?.replaceChild(doc.getElementById(@id + suffix), @build(doc, suffix))

  # @private
  createContextMenu : (doc) =>
    unless doc.getElementById(@id + '__context')?
      doc.getElementById('mainPopupSet').appendChild(@build(doc, '__context'))

  # @private
  onNewWindow : (window) =>
    doc = viewFor(window).document
    @setContextMenu(doc, target) for target in @contextMenuTargets
    @setButtonMenu(doc, target, menuOnly) for [target, menuOnly] in @menuButtonTargets

  # @private
  setContextMenu : (doc, target) =>
    @createContextMenu(doc)
    doc.getElementById(target)?.setAttribute('context', @id + '__context')

  # @private
  setButtonMenu : (doc, target, menuOnly) =>
    button = doc.getElementById(target)
    button.setAttribute('type', if menuOnly then 'menu' else 'menu-button')
    button.classList.remove('badged-button')
    button.appendChild(@build(doc, '__button__' + target))

  build : (doc, id_suffix = '') =>
    element = super(doc)
    element.setAttribute('id', @id + id_suffix)
    element

exports.Menu = Menu
exports.MenuItem = MenuItem
exports.SubMenu = SubMenu
