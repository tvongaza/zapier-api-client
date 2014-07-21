Zap.create_activity_pre_write = (bundle) ->
  outbound = JSON.parse(bundle.request.data)
  matter_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/matters?query="+outbound.activity.matter_display_number)
  matter_id = matter_response.matters[0].id
  user_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/users?query="+outbound.activity.user.email)
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
   