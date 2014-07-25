Zap.new_relationship_post_poll = (bundle)->
	results = JSON.parse(bundle.response.content)
	array = []
	for field in results.relationships
		_.defaults field,
		id:null
		contact:
			name:null
		matter:
			name:null
		#format return array
		array.push
		 id: field.id
		 contact:field.contact.name
		 matter:field.matter.name
	#return array
	array
		 
	
		 
