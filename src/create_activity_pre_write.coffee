Zap.create_activity_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.activity
  
  data = {}
  data.type = object.type
  data.date = object.date
  if object.type == "TimeEntry"
    data.quantity = object.quantity * 60*60 # hours
  else
    data.quantity = 1
  data.price = object.price
  data.note = object.note
  
  if object.user?
    user = Zap.find_user(bundle, object.user.name, object.user.question)
    if user?
      data.user_id = user.id
  
  if object.matter?
    matter = Zap.find_matter(bundle, object.matter.name, object.matter.question)
    if matter?
      data.matter_id = matter.id
  
  bundle.request.data = JSON.stringify({"activity": data})
  bundle.request   