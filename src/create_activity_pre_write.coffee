Zap.create_activity_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.activity
  
  data = {}
  data.type = object.type
  data.date = object.date
  data.quantity = object.quantity
  data.price = object.price
  data.note = object.note
  
  user = Zap.find_user(bundle, object.user.name, object.user.question)
  if user?
    data.user_id = user.id
  
  matter = Zap.find_matter(bundle, object.matter.name, object.matter.question)
  if matter?
    data.matter_id = matter.id
  
  bundle.request.data = JSON.stringify({"activity": data})
  bundle.request   