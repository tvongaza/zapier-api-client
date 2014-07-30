Zap.find_contact = (bundle,query)->
	response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/contacts?query=" + query)
	contact = null
	if response.contacts.length > 0
		contact = 
			id: response.contacts[0].id
			first_name: response.contacts[0].first_name
			last_name: response.contacts[0].last_name
			name: response.contacts[0].name
	contact
		