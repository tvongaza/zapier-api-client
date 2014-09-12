Zap.create_calendar_entry_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.calendar_entry
  
  data = {}
  data.summary = object.summary
  data.description = object.description
  if object.all_day
    data.start_date = object.start_at
    data.end_date = object.end_at
  else
    data.start_date_time = object.start_at
    data.end_date_time = object.end_at

  data.location = object.location

  matter = Zap.find_matter(bundle, object.matter.name, object.matter.question)
  if matter?
    data.matter_id = matter.id

  bundle.request.data = JSON.stringify({"calendar_entry": data})
  bundle.request