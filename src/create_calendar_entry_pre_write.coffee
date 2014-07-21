 Zap.create_calendar_entry_pre_write = (bundle) ->
    outbound = JSON.parse(bundle.request.data)
  # Set default values for non-required fields, stops Undefined exceptions.
    _.defaults outbound.calendar_entry,
      description: null
      location: null
      matter:
        id: null
      reminders:
        unit: null
        amount: null
      activities:
        id: null
    # Calculate the number of Minutes for the correct reminder time unit
    switch outbound.calendar_entry.reminders.unit
      when "Hours"
        outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 60
      when "Days"
        outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 1440
      when "Weeks"
        outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 10080
    # Reformat the reminder for the Clio API Reminders' data structure 
    outbound.calendar_entry.reminders = [
      minutes: outbound.calendar_entry.reminders.amount
      method: "Popup"
    ]
    bundle.request.data = JSON.stringify(outbound)
    bundle.request