Zap.new_contact_post_poll = (bundle) ->
  results = JSON.parse(bundle.response.content)
  array =[]
	#set defaults for attributes
	 for field in results.contacts
  	 if results.contacts.length < 1
    	 field.first_name = null
    	 field.last_name = null
    	 field.name = null
    	 field.title = null
    	 field.addresses = 
    	 field.email_addresses = []
    	 field.instant_messengers = []
    	 field.web_sites = []
    	 field.custom_field_values = []
     if field.addresses.length < 1
       field.addresses.push
         street: null
         city: null
         province: null
         postal_code: null
         country: null
     if field.phone_numbers.length < 1
       field.phone_numbers.push
         number: null
     if field.email_addresses.length < 1
       field.email_addresses.push
         address: null
     if field.instant_messengers.length < 1
       field.instant_messengers.push
         address: null
     if field.web_sites.length < 1
       field.web_sites.push
        address: null
     if field.custom_field_values.length < 1
       field.custom_field_values.push
         type: null
         value: null
         custom_field:
           name: null
         matter:
           name: null
     if typeof field.custom_field_values[0].matter is "undefined" or field.custom_field_values[0].matter is null 
       field.custom_field_values[0].matter = name: null
    
	   array.push 
       id: field.id
       title: field.title
       full_name: field.name
       first_name: field.first_name
       last_name: field.last_name
       phone_number: field.phone_numbers[0].number
       email: field.email_addresses[0].address
       street: field.addresses[0].street
       city: field.addresses[0].city
       province: field.addresses[0].province
       postal_code: field.addresses[0].postal_code
       country: field.addresses[0].country
       intant_messenger: field.instant_messengers[0].address
       web_site: field.web_sites[0].address
       matter: field.custom_field_values[0].matter.name
       custom_field_name: field.custom_field_values[0].custom_field.name
   #return array of contacts
	 array
	
	
		
	