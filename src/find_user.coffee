Zap.find_user = (bundle, query, not_found, subscription_plan) ->
  user = null
  if subscription_plan?
    subscription_plan = "&subscription_plan=#{encodeURIComponent(subscription_plan)}"
  else
    subscription_plan = ""

  if isFinite(query)
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/users?ids=#{encodeURIComponent(query)}#{subscription_plan}&limit=1")
    if response.users.length > 0
          user = response.users[0]

  unless user?
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/users?query=#{encodeURIComponent(query)}#{subscription_plan}&limit=1")
    if response.users.length > 0
      user = response.users[0]

  unless user?
    switch not_found
      when "cancel"
        throw new StopRequestException("Could not find user.")
      when "ignore"
        null #noop
      else
        throw new HaltedException('Could not find user');
    
  user