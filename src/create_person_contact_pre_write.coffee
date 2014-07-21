Zap.create_person_contact_pre_write = (bundle) ->
    outbound = JSON.parse(bundle.request.data)
    #Contact default values for phone_numbers,addresses,web_sites,instant_messengers
    _.defaults outbound.contact,
      phone_numbers:
        name: null
        number: null
      addresses:
        name: null
        street: null
        city: null
        province: null
        postal_code: null
        country: null
      web_sites:
        name: null
        address: null
      instant_messengers:
        name: null
        address: null
    #Set contact type to Person
    outbound.contact.type = "Person"
    #Creating proper format for phone number entry
    outbound.contact.phone_numbers = [
      name: outbound.contact.phone_numbers.name
      number: outbound.contact.phone_numbers.number
    ]
    #Creating proper format for email addresses entry
    #
    #        Requires that an email address is present for there to be an 
    #        email_addresses entry
    #        
    unless typeof outbound.contact.email_addresses is "undefined"
      _.defaults outbound.contact.email_addresses,
        name: null
        address: null
      if outbound.contact.email_addresses.address is null
        outbound.contact.email_addresses = []
      else
        outbound.contact.email_addresses = [
          name: outbound.contact.email_addresses.name
          address: outbound.contact.email_addresses.address
        ]
    #Creating proper format for addresses entry
    outbound.contact.addresses = [
      name: outbound.contact.addresses.name
      street: outbound.contact.addresses.street
      city: outbound.contact.addresses.city
      province: outbound.contact.addresses.province
      postal_code: outbound.contact.addresses.postal_code
      country: outbound.contact.addresses.country
    ]
    #Creating proper format for websites entry
    outbound.contact.web_sites = [
      name: outbound.contact.web_sites.name
      address: outbound.contact.web_sites.address
    ]
    #Creating proper format for instant messengers entry
    outbound.contact.instant_messengers = [
      name: outbound.contact.instant_messengers.name
      address: outbound.contact.instant_messengers.address
    ]
    #Creating proper format for custom field entry
    #
    #        Existential check for undefined variables and 
    #        stop custom_field searches with an ID = null
    #        
    unless typeof outbound.contact.custom_field_values is "undefined"
      _.defaults outbound.contact.custom_field_values,
        id: null
        value: null
      if (outbound.contact.custom_field_values.id is null) or (outbound.contact.custom_field_values.value is null)
        outbound.contact.custom_field_values = []
      else
        outbound.contact.custom_field_values = [
          custom_field:
            id: outbound.contact.custom_field_values.id

          value: outbound.contact.custom_field_values.value
        ]
    #
    #         Existential check so that no undefined variables are used 
    #         and blocks a search for a user with an ID = null
    #         
    unless typeof outbound.contact.activity_rates is "undefined"
      _.defaults outbound.contact.activity_rates,
        user: null
        rate: null
        flat_rate: null

      if (outbound.contact.activity_rates.user is null) or (outbound.contact.activity_rates.rate is null) or (outbound.contact.activity_rates.flat_rate is null)
        outbound.contact.activity_rates = []
      else
        outbound.contact.activity_rates = [
          user:
            id: outbound.contact.activity_rates.user

          rate: outbound.contact.activity_rates.rate
          flat_rate: outbound.contact.activity_rates.flat_rate
        ]
    bundle.request.data = JSON.stringify(outbound)
    bundle.request