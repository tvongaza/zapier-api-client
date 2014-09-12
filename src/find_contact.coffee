Zap.find_or_create_contact = (bundle, object, not_found) ->
  contact = Zap.find_contact(bundle, object)
  unless contact
    switch not_found
      when "Person", "Company"
        contact = Zap.create_contact(bundle, object, not_found)
      when "cancel"
        throw new StopRequestException("Could not find contact.")
      when "ignore"
        null #noop
      else
        throw new HaltedException('Could not find contact');
      
  contact

Zap.find_contact = (bundle, object) ->
  contact = null
  # if email set, try to find by it
  if object.email? && object.email != ""
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/contacts?query=#{encodeURIComponent(object.email)}&limit=1")
    if response.contacts.length > 0
      contact = response.contacts[0]
  # If no email or not found, try with the name
  if !contact? && (!object.email? || !!object.email)
    response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/contacts?name=#{encodeURIComponent(object.name)}&limit=1")
    if response.contacts.length > 0
      contact = response.contacts[0]
  contact

Zap.create_contact = (bundle, object, contact_type) ->
  data = { "type": contact_type, "name": object.name }
  # if email set, add it
  if object.email? && object.email != ""
    data["email_addresses"] = [{"name": "Work", "address": object.email}]
  response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", JSON.stringify({"contact": data}))
  unless response.hasOwnProperty("contact")
    throw new HaltedException('Could not create new contact');
  response.contact