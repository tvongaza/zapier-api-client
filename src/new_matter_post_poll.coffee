Zap.new_matter_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)

  array = []
  for object in results.matters
    # The format of this data MUST match the sample data format in triggers "Sample Result"
    # To get a sample, build a new object with good data and create a Zap, you should see
    # bundle output (from scripting editor quicklinks) once you try and add a field in the
    # Zap editor

    data = {}
    data.id = object.id
    data.created_at = object.created_at
    data.updated_at = object.updated_at
    data.display_number = object.display_number
    data.status = object.status
    data.description = object.description
    data.client_reference = object.client_reference
    data.location = object.location
    data.pending_date = object.pending_date
    data.open_date = object.open_date
    data.close_date = object.close_date
    data.billable = object.billable
    data.maildrop_address = object.maildrop_address
    data.billing_method = object.billing_method
    data.client = Zap.transform_nested_attributes(object.client)
    data.responsible_attorney = Zap.transform_nested_attributes(object.responsible_attorney)
    data.originating_attorney = Zap.transform_nested_attributes(object.originating_attorney)
    data.practice_area = Zap.transform_nested_attributes(object.practice_area)
    data.custom_fields = Zap.transform_custom_fields(bundle, object, "Matter")
    array.push data
  array