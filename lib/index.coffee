
pika = require 'pikaday'
require './pikaday.css'

module.exports = ->
	simpleFormify = new SimpleFormify()
	return simpleFormify

class SimpleFormify
  opts: {}

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

    @opts = opts

    values = {}
    if opts.values?
      values = opts.values
    result = @build struct, values
    return result

  build: (struct, values, section) ->
    holder = document.createElement 'div'
    console.log 'STRUCT', struct
    for item in struct
      if item.section?
        holder.appendChild @buildSection item, values
      else
        value = ''
        if values[item.name]?
          value = values[item.name]
        holder.appendChild @formifyField item, value, section
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
    console.log 'white', typeof whitelist
    console.log 'whitelist', whitelist
    if whitelist.fields?
      struct = []
      for section in whitelist
        section.fields = @organizeSchema schema, section.fields
        struct.push section
    else if typeof whitelist[0]?
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

  formifyField: (settings, value, section={}) ->

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
        value = settings.options[value]
      input = @buildHidden settings, value

      displayText = document.createElement 'span'
      if value?
        displayText.innerHTML = value
      holder.appendChild displayText
    else
      input = @buildInput settings, value

    classes = []
    if section.fieldClass?
      classes.push section.fieldClass
    if settings.class?
      classes.push settings.class
    if @opts.className?
      classes.push @opts.className
    if classes.length > 0
      input.className = classes.join ' '
    holder.appendChild input

    return holder


  buildInput: (settings, value) ->
    if settings.options?
      input = @buildSelect settings, value
    else
      switch settings.type
        when 'hidden'
          input = @buildHidden settings, value
          return input
        when 'time', 'date', 'datetime'
          input = @buildPicker settings, value
        when 'text', 'blob'
          input = @buildTextarea settings, value
        when 'bitflag', 'boolean'
          input = @buildCheckbox settings, value
        when 'select'
          input = @buildSelect settings, value
        else
          input = @buildText settings, value
  
    for handle, setting of settings.attributes
      input.setAttribute handle.replace(/_/g, '-'), setting

    input.name = settings.name

    if value?
      input.value = value
    return input

  buildPicker: (settings, value) ->
    field = @buildText settings
    picker = new pika
      field: field
      onSelect: (date) ->
        field.value = picker.toString()
    return field


  buildHidden: (settings, value) ->
    input = document.createElement 'input'
    input.type = 'hidden'
    return input

  buildCheckbox: (settings, value) ->
    input = document.createElement 'input'
    input.type = 'checkbox'
 
    if value is '1' or value is 1
      input.checked = 'checked'
    return input

  buildText: (settings, value) ->
    input = document.createElement 'input'
    input.type = 'text'
    return input

  buildTextarea: (settings, value) ->
    input = document.createElement 'textarea'

    rows = 8
    cols = 40
    if settings.rows?
      rows = settings.rows
      cols = settings.cols
    input.rows = rows
    input.cols = cols
    return input

  buildSelect: (settings, value) ->
    input = document.createElement 'select'
    input.type = 'text'

    for val, title of settings.options
      option = document.createElement 'option'
      option.innerHTML = title
      option.value = val
      if value is val
        option.selected = true
      input.appendChild option

    return input

