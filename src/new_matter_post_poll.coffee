Zap.new_matter_post_poll = (bundle) ->
	results = JSON.parse(bundle.response.content)
	array = []
	#loop through matters and re-format for Zapier
	for field in results.matters
		#set defaults for custom_field_values
		if field.custom_field_values.length<1
			field.custom_field_values.push
				value:null
				custom_field:
					id:null
					name:null
		#set defaults for activity_rates
		if field.activity_rates.length<1
			field.activity_rates.push
				id:null
				rate:null
				flat_rate:null
		#populate array
		array.push
			id:field.id
			display_number:field.display_number
			client_id:field.client.id
			client_name:field.client.name
			description:field.description
			open_date:field.open_date
			close_date:field.close_date
			pending_date:field.pending_date
			location:field.location
			practice_area:field.practice_area
			maildrop_address:field.maildrop_address
			custom_field_id:field.custom_field_values[0].custom_field.id
			custom_field_name:field.custom_field_values[0].custom_field.name
			custom_field_value:field.custom_field_values[0].value
			activity_id:field.activity_rates[0].id
			activity_rate:field.activity_rates[0].rate
			activity_flat_rate:field.activity_rates[0].flat_rate
	#return array
	array
		
		