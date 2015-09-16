# Base class with a few common OO methods
class CommonBase
  # Defines a new property with getter and setter
  #
  # @param [String] name The property's name
  # @param [Object] def An object describing the property.
  #   See the defineProperty documentation for details
  #
  # @example
  #   class MyClass
  #     @property 'MyProperty',
  #       get: -> @__my_property,
  #       set: (value) ->
  #         console.log("writing MyProperty")
  #         @__my_property = value
  @property : (name, def) ->
    Object.defineProperty @prototype, name, def

  # Defines a new option, a property that is stored in a "options" object
  #
  # @param [String] option The option's name
  # @param [String,Number,Boolean,Object,Array] defaultValue The option's default value
  #
  # @example
  #   class MyClass
  #     @option 'enabled', true
  @option : (option, defaultValue) ->
    @property option,
      get: -> @options?[option] ? defaultValue,
      set: (value) ->
        @options ?= {}
        [old, @options[option]] = [@[option], value]
        @onOptionChanged?(option, old, value) unless old == value

  # Defines a new "on<Event>" option
  #
  # @param [String] name The event's name
  @event : (name) ->
    @option "on#{name[0].toUpperCase()}#{name[1..]}"

  # @private
  @__instance_counter__ : 0

  # @property [Integer] Instance number for this class
  @property '__instance_number__',
    get: -> @__instance_index__ ?= @constructor.__instance_counter__++

exports.CommonBase = CommonBase
