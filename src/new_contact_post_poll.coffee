Zap.new_contact_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  
  array = []
  for object in results.contacts
    # The format of this data MUST match the sample data format in triggers "Sample Result"
    # To get a sample, build a new object with good data and create a Zap, you should see
    # bundle output (from scripting editor quicklinks) once you try and add a field in the
    # Zap editor
    
    data = {}
    data.id = object.id
    data.created_at = object.created_at
    data.updated_at = object.updated_at
    data.name = object.name
    data.first_name = object.first_name
    data.last_name = object.last_name
    data.title = object.title
    data = Zap.flatten_nested_attributes(object, data, ["company"])
    data.email_address = Zap.flatten_array(object.email_addresses , ["name","address"])
    data.phone_number = Zap.flatten_array(object.phone_numbers, ["name", "number"])
    data.instant_messenger = Zap.flatten_array(object.instant_messengers, ["name", "address"])
    data.web_site = Zap.flatten_array(object.web_sites, ["name", "address"])
    data.address = Zap.flatten_array(object.addresses, ["name", "street", "city", "province", "postal_code", "country"])
    data.custom_field = Zap.transform_custom_fields(bundle, object, "Contact")
    array.push data
  array