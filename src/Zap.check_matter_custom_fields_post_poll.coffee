check_matter_custom_fields_post_poll: (bundle) ->
    array = []
    
    #
    #        Parse the returned custom fields and fill an array with the results that are
    #        of parent_type = Matter and don't contain field_type = matter or contact (Not supported by zapier).
    #        
    results = JSON.parse(bundle.response.content)
    i = 0
    while i < results.custom_fields.length
      array.push results.custom_fields[i]  if (results.custom_fields[i].field_type isnt "contact") and (results.custom_fields[i].field_type isnt "matter") and (results.custom_fields[i].parent_type is "Matter")
      i++
    array

  