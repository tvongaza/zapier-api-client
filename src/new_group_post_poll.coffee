Zap.new_group_post_poll = (bundle)->
	results = JSON.parse(bundle.response.content)
	array=[]
	#loop through array to re-format for Zapier
	for field in results.groups
		#populate array
		array.push
			id:field.id
			name:field.name
			user_id:field.users[0].id
			user_name:field.users[0].name
			user_type:field.users[0].type
	#return array
	array
			