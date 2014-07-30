Zap.find_user = (bundle,query)->
	response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/users?query=" + query)
	user = null
	if response.users.length > 0
		user =
			id: response.users[0].id
			email: response.users[0].email
			first_name: response.users[0].first_name
			last_name: response.users[0].last_name
	user
				
		
			 
	