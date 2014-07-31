Zap.new_task_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  array = []
  #set defaults for attributes
  for field in results.tasks
    if field.reminders.length<1
      field.reminders.push
        minutes:null
        method:null
    if field.matter is null
      field.matter =
        id:null
        name:null
    #populate array
    array.push
      id:field.id
      name:field.name
      description:field.description
      priority:field.priority
      user_id:field.user.id
      user_name:field.user.name
      assingner_id:field.assigner.id
      assigner_name:field.assigner.name
      matter_id:field.matter.id
      matter_name:field.matter.name
      due_at:field.due_at
      completed:field.completed
      is_private:field.is_private
      is_statute_of_limitations:field.is_statute_of_limitations
      reminder_minutes:field.reminders[0].id
      reminder_method:field.reminders[0].method
  #return array
  array
        