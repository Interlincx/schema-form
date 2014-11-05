

module.exports = ->
	simpleFormify = new SimpleFormify()
	return simpleFormify

class SimpleFormify
  constructor: ->
    console.log 'sf instantiated'

  formifyGroup: (opts) ->
    struct = opts.struct
    if opts.schema?
      whitelist = []
      if opts.whitelist?
        whitelist = opts.whitelist
      struct = @organizeSections opts.schema, whitelist
    console.log struct

    defaultOpts =
      schema:{}
      values:{}
      fields:[]
      className:''

    values = {}
    if opts.values?
      values = opts.values
    result = @build struct, values
    return result

  build: (struct, values, section) ->
    holder = document.createElement 'div'
    for item in struct
      if item.section?
        holder.appendChild @buildSection item, values
      else
        if values[item.name]?
          item.value = values[item.name]
        holder.appendChild @formifyField item, section
    return holder

  buildSection: (section, values) ->
    sectHolder = document.createElement 'div'
    if section.title?
      title = document.createElement 'h2'
      title.innerHTML = section.title
      sectHolder.appendChild title
    sectHolder.appendChild @build section.fields, values, section
    return sectHolder


  organizeSections: (schema, whitelist=[]) ->
    if typeof whitelist is 'object'
      struct = []
      for section in whitelist
        section.fields = @organizeSchema schema, section.fields
        struct.push section
    else if typeof whitelist is 'array'
      struct = @organizeSchema schema, whitelist
    else
      struct = @organizeSchema schema
    return struct

  organizeSchema: (schema, whitelist=[]) ->
    struct = []
    if whitelist.length > 0
      for handle, i in whitelist
        if typeof handle is "object"
          if schema[handle.name]?
            data = schema[handle.name]
            for prop, val of handle
              data[prop] = val
          else
            data = handle
        else
          data = schema[handle]
          data.name = handle
        struct.push data
    else
      for handle, data of schema
        data.name = handle
        struct.push data
    return struct

  formifyField: (settings, section={}) ->
    console.log 'formify!'

    holder = document.createElement 'div'
    if section.holderClass?
      holder.className = section.holderClass

    label = document.createElement 'label'
    label.innerHTML = settings.title
    if settings.required? and settings.required is true
      label.className = 'required'
    holder.appendChild label

    ###
    if settings.tooltip?
      tt = document.createElement 'div'
      tt.className = 'icon-question-sign'
      label.appendChild tt

      $label.popover
        html: true
        trigger: 'hover'
        placement: 'bottom'
        content: ->
          settings.tooltip
    ###

    readonly = false
    if settings.readonly?
      readonly = settings.readonly

    if readonly
      if typeof settings.options != 'undefined'
        @value = settings.options[@value]
      input = @buildHidden settings

      displayText = document.createElement 'span'
      if settings.value?
        displayText.innerHTML = settings.value
      holder.appendChild displayText
    else
      input = @buildInput settings

    classes = []
    if section.fieldClass?
      classes.push section.fieldClass
    if settings.class?
      classes.push settings.class
    if classes.length > 0
      input.className = classes.join ' '
    holder.appendChild input

    return holder


  buildInput: (settings) ->
    if settings.options?
      input = @buildSelect settings
    else
      switch settings.type
        when 'hidden'
          input = @buildHidden settings
          return input
        when 'time', 'date', 'datetime'
          input = @buildPicker settings
        when 'text', 'blob'
          input = @buildTextarea settings
        when 'bitflag', 'boolean'
          input = @buildCheckbox settings
        when 'select'
          input = @buildSelect settings
        else
          input = @buildText settings
  
    for handle, value of settings.attributes
      input.setAttribute handle.replace(/_/g, '-'), value

    input.name = settings.name

    if settings.value?
      input.value = settings.value
    return input

  buildPicker: (settings) ->
    return @buildText settings


  buildHidden: (settings) ->
    input = document.createElement 'input'
    input.type = 'hidden'
    return input

  buildCheckbox: (settings) ->
    input = document.createElement 'input'
    input.type = 'checkbox'
 
    if settings.value is '1' or settings.value is 1
      input.checked = 'checked'
    return input

  buildText: (settings) ->
    input = document.createElement 'input'
    input.type = 'text'
    return input

  buildTextarea: (settings) ->
    input = document.createElement 'textarea'

    rows = 8
    cols = 40
    if settings.rows?
      rows = settings.rows
      cols = settings.cols
    input.rows = rows
    input.cols = cols
    return input

  buildSelect: (settings) ->
    input = document.createElement 'select'
    input.type = 'text'

    for val, title of settings.options
      option = document.createElement 'option'
      option.innerHTML = title
      option.value = val
      if settings.value is val
        option.selected = true
      input.appendChild option

    return input

