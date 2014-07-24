Zap.create_activity_pre_write = (bundle) ->
  outbound = JSON.parse(bundle.request.data)
  matter_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/matters?query="+outbound.activity.matter_display_number)
  _.defaults matter_response.matters,
    [id:null]
  if matter_response.matters[0].id is null or matter_response.matters.length>1
    throw new HaltedException('Invalid matter display_number')
  else
    matter_id = matter_response.matters[0].id
  user_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/users?query="+outbound.activity.user.email)
  _.defaults user_response.users,
    [id: null] 
  if user_response.users[0].id is null
    throw new HaltedException('Invalid user email')
  else
    user_id = user_response.users[0].id
  outbound = activity:
    type: outbound.activity.type
    date: outbound.activity.date
    quantity: outbound.activity.quantity
    note: outbound.activity.note
    price: outbound.activity.price
    user:
      id: user_id
    matter:
      id: matter_id
  bundle.request.data = JSON.stringify(outbound)
  bundle.request
   