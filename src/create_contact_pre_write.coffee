Zap.create_contact_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.contact
  custom_field_values = request_data.custom_fields
  
  data = {}
  data.name = object.name
  data.type = object.type
  
  if object.phone_number? && object.phone_number.number?
    phone_type = object.phone_number.name
    phone_type ?= "Work"
    data.phone_numbers = [{"name": phone_type, "number": object.phone_number.number}]
  
  if object.email_address? && object.email_address.address?
    email_address= object.email_address.name
    email_address ?= "Work"
    data.email_addresses = [{"name": phone_type, "number": object.email_address.address}]
  
  if data.type == "Person"
    company = Zap.find_or_create_contact(bundle, object.company, object.company.question)
    if company? && company.id?
      data.company_id = company.id

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
  
  bundle.request.data = JSON.stringify({"contact": data})
  bundle.request