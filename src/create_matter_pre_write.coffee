Zap.create_matter_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.matter
  custom_field_values = request_data.custom_fields
  
  data = {}
  data.status = object.status
  data.description = object.description
  data.billable = object.billable
  
  contact = Zap.find_or_create_contact(bundle, object.client, object.client.question)
  if contact? && contact.id?
    data.client_id = contact.id

  if object.responsible_attorney? && !!object.responsible_attorney.name
    responsible_attorney = Zap.find_user(bundle, object.responsible_attorney.name, object.responsible_attorney.question, "Attorney")
    if responsible_attorney? && responsible_attorney.id?
      data.responsible_attorney_id = responsible_attorney.id

  if object.originating_attorney? && !!object.originating_attorney.name
    originating_attorney = Zap.find_user(bundle, object.originating_attorney.name, object.originating_attorney.question, "Attorney")
    if originating_attorney? && originating_attorney.id?
      data.originating_attorney_id = originating_attorney.id
  
  for own custom_field_id, custom_field_data of custom_field_values
    for own custom_field_type, custom_field_value_raw of custom_field_data
      if custom_field_value_raw? && !!custom_field_value_raw
        custom_field_value = null
        data.custom_field_values ?= []
        if custom_field_type == "contact"
          contact = Zap.find_or_create_contact(bundle, {"name": custom_field_value_raw, "email": request_data.custom_field_questions_email[custom_field_id]}, request_data.custom_field_questions[custom_field_id])
          if contact?
            custom_field_value = contact.id
        else if custom_field_type == "matter"
          matter = Zap.find_matter(bundle, custom_field_value_raw, request_data.custom_field_questions[custom_field_id])
          if matter?
            custom_field_value = matter.id
        else
          custom_field_value  = custom_field_value_raw
        
        if custom_field_value?
          data.custom_field_values.push {"custom_field_id": custom_field_id, "value": custom_field_value}
  
  bundle.request.data = JSON.stringify({"matter": data})
  bundle.request