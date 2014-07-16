create_matter_pre_write: (bundle) ->
    outbound = JSON.parse(bundle.request.data)
    
    #
    #        Default values for matter. 
    #        Helps eliminate Undefined variables.
    #        
    _.defaults outbound.matter,
      billable: null
      location: null
      custom_field_values:
        value: null
        custom_field:
          id: null

    
    #
    #        Only send custom_field_values entries to the Clio API if there exists a custom field id 
    #        anda value for the custom field. If not return an empty array. Helps eliminate searches
    #        for a custom field with an ID = 0.
    #        
    if (outbound.matter.custom_field_values.value is null) or (outbound.matter.custom_field_values.custom_field.id is null)
      outbound.matter.custom_field_values = []
    else
      outbound.matter.custom_field_values = [
        custom_field:
          id: outbound.matter.custom_field_values.custom_field.id

        value: outbound.matter.custom_field_values.value
      ]
    
    #Set matter status open (wouldn't make sense to create a closed matter).
    outbound.matter.status = "Open"
    bundle.request.data = JSON.stringify(outbound)
    url: bundle.request.url
    method: bundle.request.method
    auth: bundle.request.auth
    headers: bundle.request.headers
    params: bundle.request.params
    data: bundle.request.data