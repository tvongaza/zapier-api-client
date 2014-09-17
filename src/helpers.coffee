typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
valueExists = (value) -> value not in ["", null, undefined]
valueMissing = (value) -> value in ["", null, undefined]

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
  
unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)