Zap.new_calendar_entry_post_poll = (bundle) ->
	results = JSON.parse(bundle.response.content)
	array = []
	#loop through results to reformat for Zapier
	for field in results.calendar_entries
		#default values for reminders
		if field.reminders.length<1
			field.reminders.push
				minutes:null
				method:null
		#default values for attending calendars
		if field.attending_calendars.length<1
			field.attending_calendars.push
				id:null
				name:null
				type:null
		#default values for matter
		if field.matter is null
			field.matter =
				id:null
				display_number:null
		#populate array
		array.push
			id:field.id
			calendar_id:field.calendar.id
			calendar_name:field.calendar.name
			attending_calendar_id:field.attending_calendars[0].id
			attending_calendar_name:field.attending_calendars[0].name
			attending_calendar_type:field.attending_calendars[0].type
			start_date_time:field.start_date_time
			end_date_time:field.end_date_time
			original_event_start_date_time:field.original_event_start_date_time
			summary:field.summary
			location:field.location
			matter_id:field.matter.id
			matter_name:field.matter.display_number
	#return array
	array
			
				