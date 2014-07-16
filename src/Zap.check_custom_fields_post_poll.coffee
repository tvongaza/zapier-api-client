#Checks that field_type isn't "contact" or "matter" (unsupported type for Zapier) 
  check_custom_fields_post_poll: (bundle) ->
    array = []
    results = JSON.parse(bundle.response.content)
    i = 0
    while i < results.custom_fields.length
      array.push results.custom_fields[i]  if (results.custom_fields[i].field_type isnt "contact") and (results.custom_fields[i].field_type isnt "matter") and (results.custom_fields[i].parent_type is "Contact")
      i++
    array