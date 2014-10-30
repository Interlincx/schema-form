

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

    defaultOpts =
      schema:{}
      values:{}
      fields:[]
      className:''

    result = @buildSection struct
    console.log "FRM RESULT", result
    return result

  buildSection: (struct) ->
    for section in struct
      sectHolder = document.createElement 'div'
      if section.title?
        title = document.createElement 'h2'
        title.innerHTML = section.title
        sectHolder.appendChild title
      for field in section.fields
        sectHolder.appendChild @formifyField field
    return sectHolder
        

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
      for handle in whitelist
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
    label.innerHTML settings.title
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

    edit = true
    if settings.edit?
      edit = settings.edit

    if edit
      input = @buildInput settings
    else
      if typeof settings.options != 'undefined'
        @value = settings.options[@value]
      input = @buildHidden settings

      static = document.createElement 'span'
      if settings.value?
        static.innerHTML settings.value
      holder.appendChild static

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
        label.addClass 'checkbox'
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
      input.value = 'checked'
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

