
module.exports =
  init: (attr_settings, input_settings, value, class_name='', edit=true) ->
    if typeof input_settings == 'undefined' || typeof input_settings.type == 'undefined'
      return false

    @value = value
    @class_name = class_name
    $input = @convertField(attr_settings, input_settings, edit)
    return $input

  convertField: (attr_settings, input_settings, edit) ->
    $label = $('<label/>')
    $label.html input_settings.title
    if typeof input_settings.required != "undefined" and input_settings.required is true
      $label.addClass 'required'

    if typeof input_settings.tooltip != "undefined"
      tt = document.createElement('div')
      tt.className = 'icon-question-sign'
      $label.append tt

      $label.popover
        html: true
        trigger: 'hover'
        placement: 'bottom'
        content: ->
          input_settings.tooltip
  
    if edit
      next_to = false
      if input_settings.client_visible == false
        $input = @buildHidden(input_settings)
        return $input
      else if input_settings.type == 'time' or input_settings.type == 'date' or input_settings.type == 'datetime'
        $input = @buildPicker(input_settings)
      else if input_settings.type == 'text'
        $input = @buildTextarea(input_settings)
      else if input_settings.data_type is 'bitflag' || input_settings.type is 'boolean'
        $label.addClass 'checkbox'
        $input = @buildCheckbox(input_settings)
        next_to = true
      else if typeof input_settings.options != 'undefined'
        $input = @buildSelect(input_settings)
      else
        $input = @buildText(input_settings)
    
      for handle, value of attr_settings
        $input.attr(handle.replace(/_/g, '-'), value)
  
      $input.attr('value', @value)


    if edit is false or input_settings.client_editable is false
      if typeof input_settings.options != 'undefined'
        @value = input_settings.options[@value]
      $field = @buildHidden(input_settings)
      $value = $('<span/>')
      $value.html @value
      $input = $("<span/>")
      $input.append $field
      $input.append $value
    
    $final_input = $("<div/>")
    $final_input.className = 'inputField'
    $input.addClass @class_name

    if next_to
      $label.append $input
      $final_input.append $label
    else
      $final_input.append $label, $input
  
    return $final_input[0]

  buildPicker: (input_settings) ->
    $input = @buildText( input_settings )
    picker_format =
      dateFormat: 'yy-mm-dd'
      timeFormat: 'hh:mm:ss'
      ampm: false

    #$input[input_settings.type+'picker'](picker_format)
    return $input

  buildHidden: (input_settings) ->
    $input = $('<input/>')
    $input.attr('type', 'hidden')
    $input.attr('data-input-type', 'hidden')
    return $input

  buildCheckbox: (input_settings) ->
    $input = $('<input/>')
    $input.attr('type', 'checkbox')
    $input.attr('data-input-type', 'checkbox')
 
    if @value is '1' or @value is 1
      value = 'checked'
      $input.attr('checked', value)
    return $input

  buildText: (input_settings) ->
    $input = $('<input/>')
    $input.attr('type', 'text')
    $input.attr('data-input-type', 'text')
    return $input

  buildTextarea: (input_settings) ->
    $input = $('<textarea/>')
    $input.attr('data-input-type', 'textarea')

    rows = 8
    cols = 40
    if typeof input_settings.rows != 'undefined'
      rows = input_settings.rows
      cols = input_settings.cols
    $input.attr('rows', rows)
    $input.attr('cols', cols)
    return $input

  buildSelect: (input_settings) ->
    $input = $('<select/>')
    $input.attr('type', 'text')
    $input.attr('data-input-type', 'select')
    $input.attr('value', @value)
    for option, values of input_settings.options
      $option = $('<option/>')
      $option.append values
      $option.attr('value', option)
      $input.append $option

    $input.val(@value)
    return $input




