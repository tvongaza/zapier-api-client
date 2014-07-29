Zap.time_activities_post_poll = (bundle)->
  results = JSON.parse(bundle.response.content)
  array = []
  #if matter.name or activity_description don't exist name seach key = null
  name = null
  #loop through activities to sort for timed activities and add a description
  for field in results.activities
	  #only returns activities that are part of a matter and have a description
      if field.type is "TimeEntry" and field.matter isnt null and field.activity_description isnt null
	  #set name as matter.name and activity_description.name
	      name = field.matter.name + "-" + field.activity_description.name
	      array.push 
	        id:field.id 
		       matter_name:name
  #return array
  array
			 