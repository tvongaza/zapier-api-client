Zap.create_time_entry_pre_write = (bundle) ->
  Zap.create_activity_pre_write(bundle, "TimeEntry")
Zap.create_expense_entry_pre_write = (bundle) ->
  Zap.create_activity_pre_write(bundle, "ExpenseEntry")

Zap.create_activity_pre_write = (bundle, activity_type) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.activity
  
  data = {}
  data.type = activity_type
  data.date = object.date
  data.note = object.note
  if activity_type == "TimeEntry"
    data.price = object.price
    data.quantity = object.quantity * 60*60 # input in hours, but we take seconds
  else
    # we don't support expense units, so lets fake it
    data.price = object.price * object.quantity
    data.quantity = 1
  
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