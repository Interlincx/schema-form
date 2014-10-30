

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
    console.log "FRM RESULT", result
    return result

  build: (struct, values) ->
    if struct.title?
      result = @buildSection struct, values
    else
      result = @buildForm struct, values

  buildSection: (struct, values) ->
    for section in struct
      sectHolder = document.createElement 'div'
      if section.title?
        title = document.createElement 'h2'
        title.innerHTML = section.title
        sectHolder.appendChild title
      sectHolder.appendChild @buildForm section.fields, values
    return sectHolder

  buildForm: (fields, values) ->
    formHolder = document.createElement 'div'
    for field in fields
      if values[field.name]?
        field.value = values[field.name]
      formHolder.appendChild @formifyField field
    return formHolder
        

  organizeSections: (schema, whitelist=[]) ->
    if whitelist.length > 0
      if typeof whitelist[0] is 'string'
        struct = @organizeSchema schema, whitelist
      else
        for section in whitelist
          section.fields = @organizeSchema schema, section.fields
    else
      struct = @organizeSchema schema
    return struct

  organizeSchema: (schema, whitelist=[]) ->
    struct = []
    if whitelist.length > 0
      for handle, i in whitelist
        if typeof handle is "object"
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

  formifyField: (settings, hsettings={}) ->
    console.log 'formify!'

    holder = document.createElement 'div'
    if hsettings.class?
      holder.className = hsettings.class

    label = document.createElement 'label'
    label.innerHTML = settings.title
    if settings.required? and settings.required is true
      label.className 'required'
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

    if settings.class?
      input.className = settings.class
    holder.appendChild input

    return holder


  buildInput: (settings) ->
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

    for option, value of settings.options
      option = document.createElement 'option'
      option.innerHTML = value
      if settings.value is value
        option.selected = true
      input.appendChild option

    return input

