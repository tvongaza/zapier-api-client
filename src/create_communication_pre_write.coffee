Zap.create_communication_pre_write = (bundle) ->
  request_data = JSON.parse(bundle.request.data)
  object = request_data.communication
  
  data = {}
  data.type = "EmailCommunication"
  data.subject = object.subject
  data.body = object.body
  data.date = object.date
  
  if object.sender?
    sender = Zap.find_user(bundle, object.sender.email, "ignore")
    sender ?= Zap.find_user(bundle, object.sender.name, "ignore")
    sender ?= Zap.find_or_create_contact(bundle, object.sender, object.sender.question)
    if sender? && sender.id?
      sender_type = "User"
      if sender.type? && sender.type in ["Person", "Company"]
        sender_type = "Contact"
      data.senders = [{"id": sender.id, "type": sender_type}]

  if object.receiver?
    receiver = Zap.find_user(bundle, object.receiver.email, "ignore")
    receiver ?= Zap.find_user(bundle, object.receiver.name, "ignore")
    receiver ?= Zap.find_or_create_contact(bundle, object.receiver, object.receiver.question)
    if receiver? && receiver.id?
      receiver_type = "User"
      if receiver.type? && receiver.type in ["Person", "Company"]
        receiver_type = "Contact"
      data.receivers = [{"id": receiver.id, "type": receiver_type}]

  if object.matter?
    matter = Zap.find_matter(bundle, object.matter.name, object.matter.question)
    if matter?
      data.matter_id = matter.id

  bundle.request.data = JSON.stringify({"communication": data})
  bundle.request