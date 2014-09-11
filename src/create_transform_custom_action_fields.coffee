Zap.create_contact_post_custom_action_fields = (bundle) ->
  Zap.transform_custom_action_fields(bundle)

Zap.create_matter_post_custom_action_fields = (bundle) ->
  Zap.transform_custom_action_fields(bundle)

Zap.custom_field_question = (object,choices) ->
  # Ask if how they want to handle missing matters
  question = {}
  question.required = true
  question.key = "custom_field_questions__#{object.id}"
  question.label = "If #{object.name} (#{object.field_type}) not found?"
  question.help_text = "What happens when we can't find #{object.field_type}?"
  question.type = "unicode"
  question.choices = choices
  question

Zap.transform_custom_action_fields = (bundle) ->
  results = JSON.parse(bundle.response.content)
  
  array = []
  for object in results.custom_fields
    if object.field_type not in ["time"]
      data = {}
      data.required = object.displayed
      # Encode our field type into our data key
      # We will use this later to check if it is a matter or contact
      # custom field type, if so search for the matter or contact
      data.key = "custom_fields__#{object.id}__#{object.field_type}"
      data.label = object.name
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
      
      array.push data
      
      # Ask what to do if 
      if object.field_type == "matter"
        array.push Zap.custom_field_question(object,"cancel|Stop Zap,ignore|Leave empty")
      if object.field_type == "contact"
        question = {}
        question.required = false
        question.key = "custom_field_questions_email__#{object.id}"
        question.label = "#{object.name} email"
        question.help_text = "Contact email referenced in #{object.name}. If set we will only search on email. If no contact is found, and option to create is set, we will also set the new contact's email."
        question.type = "unicode"
        array.push question
        array.push Zap.custom_field_question(object,"cancel|Stop Zap,ignore|Leave empty,Person|Create new person,Company|Create new company")
        
  array