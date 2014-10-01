Zap.create_ericson_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  client  = request_data.client
  company = request_data.company
  matter  = request_data.matter
  custom_field_values = request_data.custom_fields

  if valueExists custom_field_values
    # We are going to need to map our custom field types correctly, thus we need all our custom fields
    custom_field_definitions = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/custom_fields").custom_fields
    contact_custom_field_ids = (custom_field_definitions.filter (x) -> x.parent_type == "Contact").map (x) -> x.id
    matter_custom_field_ids = (custom_field_definitions.filter (x) -> x.parent_type == "Matter").map (x) -> x.id
  
    # build our client custom field bundle data
    client_custom_field_values= {}
    for custom_field_id in contact_custom_field_ids
      if custom_field_values["Client"][custom_field_id]?
        client_custom_field_values[custom_field_id] = custom_field_values["Client"][custom_field_id]

    # build our client custom field bundle data
    company_custom_field_values= {}
    for custom_field_id in contact_custom_field_ids
      if custom_field_values["Company"][custom_field_id]?
        company_custom_field_values[custom_field_id] = custom_field_values["Company"][custom_field_id]
  
    # build our matter custom field bundle data
    matter_custom_field_values = {}
    for custom_field_id in matter_custom_field_ids
      if custom_field_values["Matter"][custom_field_id]?
        matter_custom_field_values[custom_field_id] = custom_field_values["Matter"][custom_field_id]
  else
    client_custom_field_values = []
    company_custom_field_values= []
    matter_custom_field_values= []
  
  # Use our existing code to build company request
  request_data.contact = company
  request_data.custom_fields = company_custom_field_values
  bundle.request.data = JSON.stringify(request_data)
  company_request = Zap.create_company_pre_write(bundle)
  # Run our company request ourselves
  company_response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", company_request.data)

  # Use our existing code to build client request
  # Set our company id
  client.company_id = company_response.contact.id
  request_data.contact = client
  request_data.custom_fields = client_custom_field_values
  bundle.request.data = JSON.stringify(request_data)
  client_request = Zap.create_person_pre_write(bundle)
  # Run our client request ourselves
  client_response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", client_request.data)

  # Set our client id
  matter.client_id = client_response.contact.id
  bundle.request.data = JSON.stringify({"matter": matter, "custom_fields": matter_custom_field_values})
  return Zap.create_matter_pre_write(bundle)
  
#
# Zap.create_person_and_matter_post_custom_action_fields = (bundle) ->
#   Zap.transform_custom_action_fields(bundle, true)
#
Zap.create_ericson_post_custom_action_fields = (bundle) ->
  Zap.transform_ericson_custom_action_fields(bundle, true)

Zap.ericson_custom_field_question = (object,choices, parent_type) ->
  # Ask if how they want to handle missing matters
  question = {}
  question.required = true
  question.key = "custom_field_questions__#{parent_type}__#{object.id}"
  question.label = "[#{parent_type}] #{object.name} (#{object.field_type}) not found?"
  question.help_text = "What happens when we can't find #{object.field_type}?"
  question.type = "unicode"
  question.default = "ignore"
  question.choices = choices
  question

Zap.transform_ericson_custom_action_fields = (bundle, include_parent_type) ->  
  results = JSON.parse(bundle.response.content)
  
  array = []
  # call these one by one to keep order
  for object in (results.custom_fields.filter (x) -> x.parent_type == "Contact" )
    if object.field_type not in ["time"]
      Array::push.apply array, Zap.transform_ericson_custom_field(bundle, include_parent_type, object, "Client")
  for object in (results.custom_fields.filter (x) -> x.parent_type == "Contact" )
    if object.field_type not in ["time"]
      Array::push.apply array, Zap.transform_ericson_custom_field(bundle, include_parent_type, object, "Company")
  for object in (results.custom_fields.filter (x) -> x.parent_type == "Matter" )
    if object.field_type not in ["time"]
      Array::push.apply array, Zap.transform_ericson_custom_field(bundle, include_parent_type, object, "Matter")
  
  array
  
Zap.transform_ericson_custom_field = (bundle, include_parent_type, object, parent_type) ->
  fields = []

  data = {}
  data.required = false # don't use object.displayed, we will add required custom fields when they are ready
  # Encode our field type into our data key
  # We will use this later to check if it is a matter or contact
  # custom field type, if so search for the matter or contact
  data.key = "custom_fields__#{parent_type}__#{object.id}__#{object.field_type}"
  data.label = object.name
  if include_parent_type
    data.label = "[#{parent_type}] #{data.label}"
  
  data.help_text = "Enter a/an #{object.field_type} value"

  data.type = switch object.field_type
    when "text_line", "url", "email" then "unicode"
    when "text_area" then "text"
    when "numeric", "currency" then "decimal"
    when "checkbox" then "bool"
    when "date" then "datetime"
    when "picklist" then "int"
    when "matter", "contact" then "unicode"

  if object.field_type == "picklist"
    choices = {"none": ""}
    for option in object.custom_field_picklist_options
      unless !!option.deleted_at
        choices[option.id] = option.name
    data.choices = choices

  fields.push data

  # Ask what to do if 
  if object.field_type == "matter"
    fields.push Zap.ericson_custom_field_question(object,"cancel|Stop Zap,ignore|Leave empty", parent_type)
  if object.field_type == "contact"
    # question = {}
    # question.required = false
    # question.key = "custom_field_questions_email__#{object.id}"
    # question.label = "#{data.label} email"
    # question.help_text = "Contact email referenced in #{object.name}. If set we will only search on email. If no contact is found, and option to create is set, we will also set the new contact's email."
    # question.type = "unicode"
    # fields.push question
    fields.push Zap.ericson_custom_field_question(object,"cancel|Stop Zap,ignore|Leave empty,Person|Create new person,Company|Create new company", parent_type)
  
  fields