Zap.create_matter_pre_custom_action_fields = (bundle) ->
    #update the custom_field url to select the user chosen action field 
    bundle.request.url = bundle.request.url + "/" + bundle.action_fields.matter__custom_field_values__custom_field__id
    bundle.request

  