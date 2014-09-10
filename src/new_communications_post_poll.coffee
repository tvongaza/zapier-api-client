Zap.new_communication_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  
  array = []
  for object in results.communications
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
    data.subject = object.subject
    data.body = object.body
    data.matter = Zap.transform_nested_attributes(object.matter)
    data.sender = Zap.flatten_array(object.senders, ["id","name", "type"])
    data.receiver = Zap.flatten_array(object.receivers, ["id","name", "type"])
    array.push data
  array