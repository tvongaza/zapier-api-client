Zap.create_matter_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.matter
  custom_field_values = request_data.custom_fields
  
  data = {}
  data.status = object.status
  data.description = object.description
  data.billable = object.billable
  
  if object.client?
    contact = Zap.find_or_create_contact(bundle, object.client, object.client.question)
    if contact? && contact.id?
      data.client_id = contact.id

  if object.practice_area?
    practice_area = Zap.find_practice_area(bundle, object.practice_area.name, object.practice_area.question)
    if practice_area? && practice_area.id?
      data.practice_area_id = practice_area.id

  if object.responsible_attorney?
    responsible_attorney = Zap.find_user(bundle, object.responsible_attorney.name, object.responsible_attorney.question, "Attorney")
    if responsible_attorney? && responsible_attorney.id?
      data.responsible_attorney_id = responsible_attorney.id

  if object.originating_attorney?
    originating_attorney = Zap.find_user(bundle, object.originating_attorney.name, object.originating_attorney.question, "Attorney")
    if originating_attorney? && originating_attorney.id?
      data.originating_attorney_id = originating_attorney.id
  
  for own custom_field_id, custom_field_data of custom_field_values
    for own custom_field_type, custom_field_value_raw of custom_field_data
      if valueExists custom_field_value_raw
        custom_field_value = null
        data.custom_field_values ?= []
        if custom_field_type == "contact"
          cf_data = {"name": custom_field_value_raw}
          if request_data.custom_field_questions_email? && valueExists request_data.custom_field_questions_email[custom_field_id]
            cf_data["email"] = request_data.custom_field_questions_email[custom_field_id]
          question = null
          if request_data.custom_field_questions? && valueExists request_data.custom_field_questions[custom_field_id]
            question = request_data.custom_field_questions[custom_field_id]
          contact = Zap.find_or_create_contact(bundle, cf_data, question)
          if contact?
            custom_field_value = contact.id
        else if custom_field_type == "matter"
          question = null
          if request_data.custom_field_questions? && valueExists request_data.custom_field_questions[custom_field_id]
            question = request_data.custom_field_questions[custom_field_id]
          matter = Zap.find_matter(bundle, custom_field_value_raw, question)
          if matter?
            custom_field_value = matter.id
        else
          custom_field_value  = custom_field_value_raw
        
        if custom_field_value?
          data.custom_field_values.push {"custom_field_id": custom_field_id, "value": custom_field_value}
  
  bundle.request.data = JSON.stringify({"matter": data})
  bundle.request