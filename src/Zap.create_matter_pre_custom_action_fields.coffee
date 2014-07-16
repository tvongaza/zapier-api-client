create_matter_pre_custom_action_fields: (bundle) ->
    
    #update the custom_field url to select the user chosen action field 
    bundle.request.url = bundle.request.url + "/" + bundle.action_fields.matter__custom_field_values__custom_field__id
    bundle.request

  create_matter_post_custom_action_fields: (bundle) ->
    result = JSON.parse(bundle.response.content)
    type = undefined
    
    # match Clio custom field with Zapier custom field
    switch result.custom_field.field_type
      when "checkbox"
        type = "bool"
      when "time"
        type = "unicode"
      when "email"
        type = "unicode"
      when "numeric"
        type = "int"
      when "text_area"
        type = "text"
      when "currency"
        type = "int"
      when "date"
        type = "datetime"
      when "url"
        type = "unicode"
      when "text_line"
        type = "unicode"
    [
      type: type
      key: "matter__custom_field_values__value"
      required: false
      label: JSON.stringify(result.custom_field.name)
      help_text: "Enter a/an " + result.custom_field.field_type + " value"
    ]

  # return fields in the order you want them displayed in the UI. They'll be appended after the regular action fields 