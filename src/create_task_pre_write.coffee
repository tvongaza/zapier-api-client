Zap.create_task_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.task
  
  data = {}
  data.name = object.name
  data.due_at = object.due_at
  data.description = object.description
  data.priority = object.priority
  data.is_private = object.is_private
  
  assignee = Zap.find_user(bundle, object.assignee.name, "ignore")
  if assignee?
    data.assignee_id = assignee.id
  
  matter = Zap.find_matter(bundle, object.matter.name, object.matter.question)
  if matter?
    data.matter_id = matter.id
  
  bundle.request.data = JSON.stringify({"task": data})
  bundle.request