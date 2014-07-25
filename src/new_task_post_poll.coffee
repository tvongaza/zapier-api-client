Zap.new_task_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
	 array = []
	 #parse returned tasks
	 for field in results.tasks
		 _.defaults field,
		 id: null
		 name: null
		 description: null
		 priority:null
		 user:
			 id:null
			 name:null
		 assigner:
			 id:null
			 name:null
		 matter:
			 id:null
			 name:null
		 due_at:null
		 completed_at:null
     #add results to array in proper format	
		 array.push
		  id:field.id
		  name:field.name
		  description:field.description
		  priority:field.priority
		  user:field.user.name
		  assigner:field.assigner.name
		  matter: field.matter.name
		  due_at:field.due_at
		  completed_at:field.completed_at
	 #return array
	 array
	
	
    