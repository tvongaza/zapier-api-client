typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output
  
unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)