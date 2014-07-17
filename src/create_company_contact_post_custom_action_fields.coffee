Zap.create_company_contact_post_custom_action_fields = (bundle) ->
    result = JSON.parse(bundle.response.content)
    type = undefined
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
      key: "contact__custom_field_values__value"
      required: false
      label: JSON.stringify(result.custom_field.name)
      help_text: "Enter a/an " + result.custom_field.field_type + " value"
    ]
