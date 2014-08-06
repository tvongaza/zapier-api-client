Zap.new_matter_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  array = [] 
  for field in results.matters
    custom_fields = {}
    rates = {}
    if typeof field.activity_rates is "undefined"
      field.activity_rates = []
    for field_1 in field.activity_rates
      rates[field_1.user.name+" rate/hr"] = field_1.rate
    field.activity_rates = rates
    for field_2 in field.custom_field_values
      custom_fields[field_2.custom_field.name] = field_2.value
    field.custom_field_values = custom_fields
    array.push field
  array
		
		