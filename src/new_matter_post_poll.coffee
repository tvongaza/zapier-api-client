Zap.new_matter_pre_poll = (bundle) ->
  request_bundle = {
    url: bundle.request.url,
    method: bundle.request.method,
    auth: bundle.request.auth,
    headers: bundle.request.headers,
    params: bundle.request.params,
    data: bundle.request.data
  }
  for own key, value in bundle.trigger_fields
    request_bundle.url = "#{request_bundle.url}&#{key}=#{value}"
  request_bundle

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
    data = Zap.flatten_nested_attributes(object, data, ["client", "responsible_attorney", "originating_attorney", "practice_area"])
    data.custom_fields = Zap.transform_custom_fields(bundle, object, "Matter")
    array.push data
  array