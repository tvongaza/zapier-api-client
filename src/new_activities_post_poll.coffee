Zap.new_activity_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  
  array = []
  for object in results.activities
    # The format of this data MUST match the sample data format in triggers "Sample Result"
    # To get a sample, build a new object with good data and create a Zap, you should see
    # bundle output (from scripting editor quicklinks) once you try and add a field in the
    # Zap editor

    data = {}
    data.id = object.id
    data.created_at = object.created_at
    data.updated_at = object.updated_at
    data.type = object.type
    data.date = object.date
    data.quantity = object.quantity
    data.price = object.price
    data.total = object.total
    data.note = object.note
    data.billed = object.billed
    data.activity_description = Zap.transform_nested_attributes(object.activity_description)
    data.user = Zap.transform_nested_attributes(object.user)
    data.matter = Zap.transform_nested_attributes(object.matter)
    data.bill = Zap.transform_nested_attributes(object.bill)
    array.push data
  array