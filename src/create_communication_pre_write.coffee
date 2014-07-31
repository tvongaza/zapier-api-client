Zap.create_communication_pre_write = (bundle) ->
  outbound = JSON.parse(bundle.request.data)
  sender_type = undefined
  sender_id = null
  receiver_type = undefined
  receiver_id = null
  matter_id = null
  
  #check for user with email_receiver
  user = Zap.find_user(bundle,outbound.communication.email_receiver)
  if user isnt null
    receiver_id = user.id
    receiver_type = "User"
  
  #check for contact with email_receiver
  if receiver_id is null
    contact = Zap.find_contact(bundle,outbound.communication.email_receiver)
    if contact isnt null
      receiver_id = contact.id
      receiver_type = "Contact"
  
  #create new contact with receiver email/name
  if receiver_id is null and outbound.communication.new_contact is true
    receiver_data = JSON.stringify(contact:
      type: "Person"
      name: outbound.communication.receiver_name
      first_name: outbound.communication.receiver_name.split(" ")[0]
      last_name: outbound.communication.receiver_name.split(" ")[1]
      email_addresses: [
        name: "Work"
        address: outbound.communication.email_receiver
      ]
    )
    contact_response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", receiver_data)
    receiver_id = contact_response.contact.id
    receiver_type = "Contact"
    
  #check for user with email_sender
  user = Zap.find_user(bundle,outbound.communication.email_sender)
  if user isnt null
    sender_id = user.id
    sender_type = "User"
  
  #check for contact with email_sender
  if sender_id is null
    contact = Zap.find_contact(bundle,outbound.communication.email_sender)
    if contact isnt null
      sender_id = contact.id
      sender_type = "Contact"
  
  #create new contact with sender email/name
  if sender_id is null and outbound.communication.new_contact is true
    sender_data = JSON.stringify(contact:
      type: "Person"
      name: outbound.communication.sender_name
      first_name: outbound.communication.sender_name.split(" ")[0]
      last_name: outbound.communication.sender_name.split(" ")[1]
      email_addresses: [
        name: "Work"
        address: outbound.communication.email_sender
      ]
    )
    contact_response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", sender_data)
    sender_id = contact_response.contact.id
    sender_type = "Contact"
  _.defaults outbound.communication,
    subject: null
    body: null
    matter:
      id: null

  
  #add reference to  sender matter
  matter_id = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/matters?status=Open&client_id=" + sender_id)  if sender_type is "Contact" and outbound.communication.add_matter_sender is true
  
  #add reference to receiver matter
  matter_id = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/matters?status=Open&client_id=" + receiver_id)  if receiver_type is "Contact" and outbound.communication.add_matter_receiver is true
  
  #set default values for matter_id
  matter_id = matters: [id: null]  if matter_id is null or matter_id.records is 0
  
  #throw exception if sender_id hasn't been found
  throw new StopRequestException("Not a valid sender email, check email or select add contact")  if sender_id is null
  
  #throw exception if receiver id hasn't been found
  throw new StopRequestException("Not a valid receiver email, check email or select add contact")  if receiver_id is null
  
  #reformat outbound for Zapier
  outbound = communication:
    type: "EmailCommunication"
    subject: outbound.communication.subject
    body: outbound.communication.body
    matter:
      id: matter_id.matters[0].id

    senders: [
      id: sender_id
      type: sender_type
    ]
    receivers: [
      id: receiver_id
      type: receiver_type
    ]

  bundle.request.data = JSON.stringify(outbound)
  bundle.request
