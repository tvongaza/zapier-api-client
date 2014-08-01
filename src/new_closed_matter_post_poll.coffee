Zap.new_closed_matter_post_poll = (bundle) ->
	results = JSON.parse(bundle.response.content)
	array = []
	#loop through time_line and add closed_matters for Zapier
	for field in results.timeline_events
    if field.event_type is "firm_feed_matter_update"
      array.push field
  #return array
  array