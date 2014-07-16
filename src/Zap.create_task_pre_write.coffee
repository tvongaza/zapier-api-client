create_task_pre_write: (bundle) ->
    outbound = JSON.parse(bundle.request.data)
    
    #default reminder values
    _.defaults outbound.task,
      reminders:
        unit: null
        amount: null

    
    #Unit of time chosen
    reminderTimeUnit = outbound.task.reminders.unit
    
    #Amount of time
    reminderAmount = outbound.task.reminders.amount
    
    #Time conversion to minutes
    switch reminderTimeUnit
      when "Hours"
        reminderAmount = reminderAmount * 60
      when "Days"
        reminderAmount = reminderAmount * 1440
      when "Weeks"
        reminderAmount = reminderAmount * 10080
    
    # entry into reminders list
    outbound.task.reminders = [
      minutes: reminderAmount
      method: "Popup"
    ]
    bundle.request.data = JSON.stringify(outbound)
    bundle.request