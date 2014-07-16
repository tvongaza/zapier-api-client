 new_contact_post_poll: (bundle) ->
    results = JSON.parse(bundle.response.content)
    
    #index for array traversal
    i = 0
    
    #array to be returned
    array = []
    while i < results.contacts.length
      
      # if no contacts exist
      if results.contacts.length < 1
        results.contacts[i].first_name = null
        results.contacts[i].last_name = null
        results.contacts[i].name = null
        results.contacts[i].title = null
        results.contacts[i].addresses[0] = null
        results.contacts[i].email_addresses[0] = null
        results.contacts[i].instant_messengers[0] = null
        results.contacts[i].web_sites[0] = null
        results.contacts[i].custom_field_values[0] = null
      
      #checking existence of keys and defining keys if needed
      if results.contacts[i].addresses.length < 1
        results.contacts[i].addresses.push
          street: null
          city: null
          province: null
          postal_code: null
          country: null

      results.contacts[i].phone_numbers[0] = number: null  if results.contacts[i].phone_numbers.length < 1
      results.contacts[i].email_addresses[0] = address: null  if results.contacts[i].email_addresses.length < 1
      results.contacts[i].instant_messengers[0] = address: null  if results.contacts[i].instant_messengers.length < 1
      results.contacts[i].web_sites[0] = address: null  if results.contacts[i].web_sites.length < 1
      if results.contacts[i].custom_field_values.length < 1
        results.contacts[i].custom_field_values[0] =
          type: null
          value: null
          custom_field:
            name: null

          matter:
            name: null
      results.contacts[i].custom_field_values[0].matter = name: null  if typeof results.contacts[i].custom_field_values[0].matter is "undefined"
      
      # 
      #            Making the contact information accessible 
      #            (taking certain info out of array form and adding user friendly labels) 
      #            and adding contact info entries into the return array
      #            
      array.push
        id: results.contacts[i].id
        title: results.contacts[i].title
        full_name: results.contacts[i].name
        first_name: results.contacts[i].first_name
        last_name: results.contacts[i].last_name
        phone_number: results.contacts[i].phone_numbers[0].number
        email: results.contacts[i].email_addresses[0].address
        street: results.contacts[i].addresses[0].street
        city: results.contacts[i].addresses[0].city
        province: results.contacts[i].addresses[0].province
        postal_code: results.contacts[i].addresses[0].postal_code
        country: results.contacts[i].addresses[0].country
        instant_messenger: results.contacts[i].instant_messengers[0].address
        web_site: results.contacts[i].web_sites[0].address
        matter: results.contacts[i].custom_field_values[0].matter.name
        custom_field_name: results.contacts[i].custom_field_values[0].custom_field.name

      i++
    
    #reverse contact array for reverse-chronological order
    array.reverse()