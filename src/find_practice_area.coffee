Zap.find_practice_area = (bundle, query, not_found) ->
  practice_area = null
  
  if isFinite(query)
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/practice_areas/#{encodeURIComponent(query)}")
    if response.practice_area?
      practice_area = response.practice_area

  unless practice_area?
    # We don't have a query method, instead filter by hand, there shouldn't be too, too many
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/practice_areas")
    practice_area = (response.practice_areas.filter (x) -> x.name == query)[0]

  unless practice_area?
    switch not_found
      when "cancel"
        throw new StopRequestException("Could not find practice area.")
      when "ignore"
        null #noop
      else
        throw new HaltedException('Could not find practice area');
    
  practice_area