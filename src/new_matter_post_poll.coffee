Zap.new_matter_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  array = [] 
  all_custom_arr = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/custom_fields").custom_fields
  matter_custom_arr = []
  #get all matter custom fields
  for custom in all_custom_arr
    if custom.parent_type is "Matter" and custom.field_type not in ["contact","matter"]
      matter_custom_arr.push custom
  #ignored keys
  ignored_fields = ["activity_rates","flat_rate_activity","flat_rate_rate","flat_rate_activity_description"]
  #create custom_fields hash
  for field in results.matters
    custom_fields = {}
    value = null 
    for field_2 in matter_custom_arr
      for field_3 in field.custom_field_values
        if field_2.id is field_3.custom_field.id
          value = field_3.value
      custom_fields[field_2.name] = value
    field.custom_field_values = custom_fields
    for key in ignored_fields
      if field.hasOwnProperty(key)
        delete field[key]
    array.push field
  array
		
		