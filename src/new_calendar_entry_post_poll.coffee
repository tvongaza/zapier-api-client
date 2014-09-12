Zap.new_calendar_entry_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  
  array = []
  for object in results.calendar_entries
    # The format of this data MUST match the sample data format in triggers "Sample Result"
    # To get a sample, build a new object with good data and create a Zap, you should see
    # bundle output (from scripting editor quicklinks) once you try and add a field in the
    # Zap editor

    data = {}
    data.id = object.id
    data.created_at = object.created_at
    data.updated_at = object.updated_at
    data.summary = object.summary
    data.description = object.description
    data.location = object.location
    data.permission = object.permission
    data.start_at = object.start_date or object.start_date_time
    data.end_at = object.end_date or object.end_date_time
    data.matter = Zap.transform_nested_attributes(object.matter)
    data.calendar = Zap.transform_nested_attributes(object.calendar)
    array.push data
  array