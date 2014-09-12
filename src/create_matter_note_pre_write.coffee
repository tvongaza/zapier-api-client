Zap.create_matter_note_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.note
  
  data = {}
  data.subject = object.subject
  data.detail = object.detail
  data.date = object.date

  matter = Zap.find_matter(bundle, object.matter.name, "cancel")
  if matter?
    data.matter_id = matter.id

  bundle.request.data = JSON.stringify({"note": data})
  bundle.request