Zap.new_communication_post_poll = (bundle)->
	results = JSON.parse(bundle.response.content)
	array = []
	for field in results.communications
		#defaults incase senders=[] or receivers = []
		_.defaults field.senders,
		[
		  id:null
		  name:null
		]
		_.defaults field.receivers,
		[
		  id:null
		  name:null
		]
		if field.matter is null
			field.matter =
				id:null
				name:null
		#populate array
		array.push
		 id:field.id
		 type:field.type
		 date:field.date
		 subject:field.subject
		 body:field.body
		 matter_id:field.matter.id
		 matter_name:field.matter.name
		 sender_id:field.senders[0].id
		 sender_name:field.senders[0].name
		 receiver_id:field.receivers[0].id
		 receiver_name:field.receivers[0].name
	#return array
	array
		 
		