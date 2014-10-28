

module.exports = ->
	simpleFormify = new SimpleFormify()
	return simpleFormify

class SimpleFormify
  constructor: ->
    console.log 'sf instantiated'

  formifyGroup: (opts) ->
    defaultOpts =
      schema:{}
      values:{}
      fields:[]
      className:''

  formifyField: (opts) ->
