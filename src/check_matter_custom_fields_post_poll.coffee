Zap.check_matter_custom_fields_post_poll = (bundle) ->
    array = []
    
    #
    #        Parse the returned custom fields and fill an array with the results that are
    #        of parent_type = Matter and don't contain field_type = matter or contact (Not supported by zapier).
    #        
    results = JSON.parse(bundle.response.content)
    
    
    for field in results.custom_fields
        if field.parent_type is "Matter" and
        field.field_type not in ["contact","matter"]

           array.push field
    array

  