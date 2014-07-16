var Zap = {


    check_matter_custom_fields_post_poll: function (bundle) {
        var array = [];
        /*
        Parse the returned custom fields and fill an array with the results that are
        of parent_type = Matter and don't contain field_type = matter or contact (Not supported by zapier).
        */


        var results = JSON.parse(bundle.response.content);
        for (i = 0; i < results.custom_fields.length; i++) {
            if ((results.custom_fields[i].field_type != "contact") && (results.custom_fields[i].field_type != "matter") && (results.custom_fields[i].parent_type == "Matter")) {

                array.push(results.custom_fields[i]);

            }
        }


        return array;
    },



    create_matter_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);

        /*
        Default values for matter. 
        Helps eliminate Undefined variables.
        */

        _.defaults(outbound.matter, {
            billable: null,
            location: null,
            custom_field_values: {
                value: null,
                custom_field: {
                    id: null
                }
            }

        });

        /*
        Only send custom_field_values entries to the Clio API if there exists a custom field id 
        anda value for the custom field. If not return an empty array. Helps eliminate searches
        for a custom field with an ID = 0.
        */

        if ((outbound.matter.custom_field_values.value === null) || (outbound.matter.custom_field_values.custom_field.id === null)) {
            outbound.matter.custom_field_values = [];
        } else {


            outbound.matter.custom_field_values = [{
                custom_field: {
                    id: outbound.matter.custom_field_values.custom_field.id
                },
                value: outbound.matter.custom_field_values.value
            }];

        }

        //Set matter status open (wouldn't make sense to create a closed matter).
        outbound.matter.status = "Open";



        bundle.request.data = JSON.stringify(outbound);



        return {
            url: bundle.request.url,
            method: bundle.request.method,
            auth: bundle.request.auth,
            headers: bundle.request.headers,
            params: bundle.request.params,
            data: bundle.request.data
        };
    },



    create_matter_pre_custom_action_fields: function (bundle) {
        //update the custom_field url to select the user chosen action field 

        bundle.request.url = bundle.request.url + "/" + bundle.action_fields.matter__custom_field_values__custom_field__id;

        return bundle.request;
    },

    create_matter_post_custom_action_fields: function (bundle) {
        var result = JSON.parse(bundle.response.content);

        var type;

        // match Clio custom field with Zapier custom field

        switch (result.custom_field.field_type) {
        case "checkbox":
            type = "bool";
            break;
        case "time":
            type = "unicode";
            break;
        case "email":
            type = "unicode";
            break;
        case "numeric":
            type = "int";
            break;
        case "text_area":
            type = "text";
            break;
        case "currency":
            type = "int";
            break;
        case "date":
            type = "datetime";
            break;
        case "url":
            type = "unicode";
            break;
        case "text_line":
            type = "unicode";
            break;

        }

        return [{
            "type": type,
            "key": "matter__custom_field_values__value",
            "required": false,
            "label": JSON.stringify(result.custom_field.name),
            "help_text": "Enter a/an " + result.custom_field.field_type + " value"
        }]; // return fields in the order you want them displayed in the UI. They'll be appended after the regular action fields 
    },


    create_calendar_entry_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);

        // Set default values for non-required fields, stops Undefined exceptions.

        _.defaults(outbound.calendar_entry, {

            description: null,
            location: null,
            matter: {
                id: null
            },
            reminders: {
                unit: null,
                amount: null
            },
            activities: {
                id: null
            }
        });

        // Calculate the number of Minutes for the correct reminder time unit

        switch (outbound.calendar_entry.reminders.unit) {
        case "Hours":
            outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 60;
            break;
        case "Days":
            outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 1440;
            break;
        case "Weeks":
            outbound.calendar_entry.reminders.amount = outbound.calendar_entry.reminders.amount * 10080;
            break;
        }

        // Reformat the reminder for the Clio API Reminders' data structure 

        outbound.calendar_entry.reminders = [{
            minutes: outbound.calendar_entry.reminders.amount,
            method: "Popup"
        }];




        bundle.request.data = JSON.stringify(outbound);


        return {
            url: bundle.request.url,
            method: bundle.request.method,
            auth: bundle.request.auth,
            headers: bundle.request.headers,
            params: bundle.request.params,
            data: bundle.request.data
        };

    },




    create_communication_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);

        var sender_type;

        var sender_id = null;

        var receiver_type;

        var receiver_id = null;


        // Search for existing User with email_receiver

        var user_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/users?query=" + outbound.communication.email_receiver);

        /*
        If the returned User search is successful,
        then update the receiver_id and receiver_type with 
        the found User data.
        */

        if (user_response.users.length > 0) {
            receiver_id = user_response.users[0].id;
            receiver_type = "User";
        }

        // Search for existing Contact with email_receiver


        var contact_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/contacts?query=" + outbound.communication.email_receiver);

        /*
         If the returned Contact search is successful,
         then update the receiver_id and receiver_type with 
         the found Contact data.
         */


        if (contact_response.contacts.length > 0) {
            receiver_id = contact_response.contacts[0].id;
            receiver_type = "Contact";
        }

        /*
    If the email of the Communication's receiver isn't recognised as
    an existing User or Contact then a Contact is created using the 
    email and name of the receiverand the Communication's receiver 
    will be associated with it.
    */

        if (receiver_id === null) {


            var receiver_data = JSON.stringify({
                "contact": {
                    "type": "Person",
                    "name": outbound.communication.receiver_name,
                    "first_name": outbound.communication.receiver_name.split(" ")[0], // used to split the full name *clearly wont work in every situation
                    "last_name": outbound.communication.receiver_name.split(" ")[1], // used to split the full name *clearly wont work in every situation
                    "email_addresses": [{
                        "name": "Work",
                        "address": outbound.communication.email_receiver
                    }]

                }
            });



            contact_response = Zap.make_post_request(bundle,"https://app.goclio.com/api/v2/contacts", receiver_data);
            receiver_id = contact_response.contact.id;
            receiver_type = "Contact";

        }

        // Search Users for existence of sender_id

        user_response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/users?query=" + outbound.communication.email_sender);
        /*
        If the returned User search is successful,
        then update the sender_id and sender_type with 
        the found User data.
        */

        if (user_response.users.length > 0) {
            sender_id = user_response.users[0].id;
            sender_type = "User";
        }


        // Search Contacts for existence of email_sender

        contact_response = Zap.make_get_request(bundle, "https://app.goclio.com/api/v2/contacts?query=" + outbound.communication.email_sender);

        /*
        If the returned Contact search is successful,
        then update the sender_id and sender_type with 
        the found Contact data.
        */


        if (contact_response.contacts.length > 0) {
            sender_id = contact_response.contacts[0].id;
            sender_type = "Contact";
        }

        /*
        If the email of the Communication's sender isn't recognised as
        an existing User or Contact then a Contact is created and the
        Communication's sender will be associated with it.
        */

        if (sender_id === null) {



            var sender_data = JSON.stringify({
                "contact": {
                    "type": "Person",
                    "name": outbound.communication.sender_name,
                    "first_name": outbound.communication.sender_name.split(" ")[0],
                    "last_name": outbound.communication.sender_name.split(" ")[1],
                    "email_addresses": [{
                        "name": "Work",
                        "address": outbound.communication.email_sender
                    }]

                }
            });



            contact_response = Zap.make_post_request(bundle, "https://app.goclio.com/api/v2/contacts", sender_data);
            sender_id = contact_response.contact.id;
            sender_type = "Contact";

        }

        /*
        Default values for outbound.communication. 
        Stops undefined variable references. 
        */
        _.defaults(outbound.communication, {
            subject: null,
            body: null,
            matter: {
                id: null
            }
        });

        /*
        Reformat outbound data to be appropriate for 
        the Clio API Communications' data structure.
        */
        outbound = {
            "communication": {
                "type": "EmailCommunication",
                "subject": outbound.communication.subject,
                "body": outbound.communication.body,
                "matter": {
                    id: outbound.communication.matter.id
                },
                "senders": [{
                    id: sender_id,
                    type: sender_type
                }],
                "receivers": [{
                    id: receiver_id,
                    type: receiver_type
                }]
            }
        };



        bundle.request.data = JSON.stringify(outbound);

        return {
            url: bundle.request.url,
            method: bundle.request.method,
            auth: bundle.request.auth,
            headers: bundle.request.headers,
            params: bundle.request.params,
            data: bundle.request.data
        };



    },




    contact_note_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);



        //Internal poll for Clio Contact with provided email_address



        // Creating readable JSON object for Clio Contact
        var response = Zap.make_get_request(bundle,"https://app.goclio.com/api/v2/contacts?query=" + outbound.notes.email);



        //var for contact id number
        var contact_id;


        // If contact doesn't exist create a new contact
        if (response.contacts.length < 1) {

            var data = bundle.action_fields;



            //Outbound request for new Clio contact creation


            var contact = JSON.stringify({
                "contact": {
                    "type": "Person",
                    "name": data.notes.name,
                    "first_name": data.notes.name.split(" ")[0],
                    "last_name": data.notes.name.split(" ")[1],
                    "email_addresses": [{
                        "name": "Work",
                        "address": data.notes.email
                    }]

                }
            });



            var create_response = Zap.make_post_request(bundle,"https://app.goclio.com/api/v2/contacts", contact);
            contact_id = create_response.contact.id;

        } else {

            // if contact previously existed
            contact_id = response.contacts[0].id;

        }

        /*
        Reformating data to fit Clio Notes' format. 
        If there are multiple Contacts with the 
        same email only the top Contact will be referred to 
        (assume there are unique email addresses).
        */
        outbound = {
            note: {
                subject: outbound.notes.subject,
                detail: outbound.notes.detail,
                regarding: {
                    type: "Contact",
                    id: contact_id
                }


            }


        };


        bundle.request.data = JSON.stringify(outbound);

        return {
            url: bundle.request.url,
            method: bundle.request.method,
            auth: bundle.request.auth,
            headers: bundle.request.headers,
            params: bundle.request.params,
            data: bundle.request.data
        }; // or return bundle.request;


    },




    new_contact_post_poll: function (bundle) {
        var results = JSON.parse(bundle.response.content);


        //index for array traversal
        var i = 0;
        //array to be returned
        var array = [];


        while (i < results.contacts.length) {

            // if no contacts exist
            if (results.contacts.length < 1) {
                results.contacts[i].first_name = null;
                results.contacts[i].last_name = null;
                results.contacts[i].name = null;
                results.contacts[i].title = null;
                results.contacts[i].addresses[0] = null;
                results.contacts[i].email_addresses[0] = null;
                results.contacts[i].instant_messengers[0] = null;
                results.contacts[i].web_sites[0] = null;
                results.contacts[i].custom_field_values[0] = null;
            }


            //checking existence of keys and defining keys if needed

            if (results.contacts[i].addresses.length < 1) {

                results.contacts[i].addresses.push({
                    street: null,
                    city: null,
                    province: null,
                    postal_code: null,
                    country: null
                });

            }

            if (results.contacts[i].phone_numbers.length < 1) {
                results.contacts[i].phone_numbers[0] = {
                    number: null
                };
            }


            if (results.contacts[i].email_addresses.length < 1) {

                results.contacts[i].email_addresses[0] = {
                    address: null
                };

            }

            if (results.contacts[i].instant_messengers.length < 1) {

                results.contacts[i].instant_messengers[0] = {
                    address: null
                };

            }

            if (results.contacts[i].web_sites.length < 1) {



                results.contacts[i].web_sites[0] = {
                    address: null
                };

            }

            if (results.contacts[i].custom_field_values.length < 1) {

                results.contacts[i].custom_field_values[0] = {

                    type: null,
                    value: null,
                    custom_field: {
                        name: null
                    },
                    matter: {
                        name: null
                    }

                };

            }

            if (typeof results.contacts[i].custom_field_values[0].matter == "undefined") {

                results.contacts[i].custom_field_values[0].matter = {
                    name: null
                };

            }


            /* 
            Making the contact information accessible 
            (taking certain info out of array form and adding user friendly labels) 
            and adding contact info entries into the return array
            */

            array.push({
                id: results.contacts[i].id,
                title: results.contacts[i].title,
                full_name: results.contacts[i].name,
                first_name: results.contacts[i].first_name,
                last_name: results.contacts[i].last_name,
                phone_number: results.contacts[i].phone_numbers[0].number,
                email: results.contacts[i].email_addresses[0].address,
                street: results.contacts[i].addresses[0].street,
                city: results.contacts[i].addresses[0].city,
                province: results.contacts[i].addresses[0].province,
                postal_code: results.contacts[i].addresses[0].postal_code,
                country: results.contacts[i].addresses[0].country,
                instant_messenger: results.contacts[i].instant_messengers[0].address,
                web_site: results.contacts[i].web_sites[0].address,
                matter: results.contacts[i].custom_field_values[0].matter.name,
                custom_field_name: results.contacts[i].custom_field_values[0].custom_field.name
            });



            i++;


        }

        //reverse contact array for reverse-chronological order
        return array.reverse();



    },




    new_task_post_poll: function (bundle) {
        var results = JSON.parse(bundle.response.content);
        //reverse task array for reverse-chronological order
        return results.tasks.reverse();

    },




    //Checks that field_type isn't "contact" or "matter" (unsupported type for Zapier) 

    check_custom_fields_post_poll: function (bundle) {

        var array = [];
        var results = JSON.parse(bundle.response.content);
        for (i = 0; i < results.custom_fields.length; i++) {
            if ((results.custom_fields[i].field_type != "contact") && (results.custom_fields[i].field_type != "matter") && (results.custom_fields[i].parent_type == "Contact")) {

                array.push(results.custom_fields[i]);

            }
        }


        return array;

    },




    create_company_contact_pre_custom_action_fields: function (bundle) {


        //update the custom_field url to select the user chosen action field 

        bundle.request.url = bundle.request.url + "/" + bundle.action_fields.contact__custom_field_values__id;

        return bundle.request;
    },




    create_company_contact_post_custom_action_fields: function (bundle) {

        var result = JSON.parse(bundle.response.content);

        var type;


        switch (result.custom_field.field_type) {
        case "checkbox":
            type = "bool";
            break;
        case "time":
            type = "unicode";
            break;
        case "email":
            type = "unicode";
            break;
        case "numeric":
            type = "int";
            break;
        case "text_area":
            type = "text";
            break;
        case "currency":
            type = "int";
            break;
        case "date":
            type = "datetime";
            break;
        case "url":
            type = "unicode";
            break;
        case "text_line":
            type = "unicode";
            break;

        }




        return [{
            "type": type,
            "key": "contact__custom_field_values__value",
            "required": false,
            "label": JSON.stringify(result.custom_field.name),
            "help_text": "Enter a/an " + result.custom_field.field_type + " value"
        }]; // return fields in the order you want them displayed in the UI. They'll be appended after the regular action fields
    },




    create_company_contact_pre_write: function (bundle) {


        var outbound = JSON.parse(bundle.request.data);


        //Contact default values for phone_numbers,addresses,web_sites,instant_messengers

        _.defaults(outbound.contact, {

            phone_numbers: {
                name: null,
                number: null
            },
            addresses: {
                name: null,
                street: null,
                city: null,
                province: null,
                postal_code: null,
                country: null
            },
            web_sites: {
                name: null,
                address: null
            },
            instant_messengers: {
                name: null,
                address: null
            }

        });



        //Choosing company contact type
        outbound.contact.type = "Company";


        //Creating proper Clio API format for phone number entry

        outbound.contact.phone_numbers = [

            {
                name: outbound.contact.phone_numbers.name,
                number: outbound.contact.phone_numbers.number
            }

        ];

        //Creating proper Clio API format for email addresses entry

        /*
         Existential check so undefined variables aren't sent and that
         an Email address is required
        */
        if (typeof outbound.contact.email_addresses != "undefined") {



            _.defaults(outbound.contact.email_addresses, {
                name: null,
                address: null
            });

            if (outbound.contact.email_addresses.address === null) {
                outbound.contact.email_addresses.address = [];
            } else {


                outbound.contact.email_addresses = [

                    {
                        name: outbound.contact.email_addresses.name,
                        address: outbound.contact.email_addresses.address
                    }

                ];


            }
        }

        //Creating proper Clio API format for addresses entry



        outbound.contact.addresses = [

            {
                name: outbound.contact.addresses.name,
                street: outbound.contact.addresses.street,
                city: outbound.contact.addresses.city,
                province: outbound.contact.addresses.province,
                postal_code: outbound.contact.addresses.postal_code,
                country: outbound.contact.addresses.country
            }

        ];


        //Creating proper Clio API format for websites entry



        outbound.contact.web_sites = [

            {
                name: outbound.contact.web_sites.name,
                address: outbound.contact.web_sites.address
            }

        ];

        //Creating proper Clio API format for instant messengers entry



        outbound.contact.instant_messengers = [

            {
                name: outbound.contact.instant_messengers.name,
                address: outbound.contact.instant_messengers.address
            }


        ];

        //Creating proper Clio API format for custom field entry

        /*
        Existential check for undefined variables and 
        stop custom_field searches with an ID = null
        */

        if (typeof outbound.contact.custom_field_values != "undefined") {



            _.defaults(outbound.contact.custom_field_values, {
                id: null,
                value: null
            });

            if ((outbound.contact.custom_field_values.id === null) || (outbound.contact.custom_field_values.value === null)) {
                outbound.contact.custom_field_values = [];
            } else {

                outbound.contact.custom_field_values = [

                    {

                        custom_field: {
                            id: outbound.contact.custom_field_values.id
                        },

                        value: outbound.contact.custom_field_values.value

                    }
                ];

            }

        }



        //Creating proper Clio API format for activity rate entry

        /*
        Existential check so that no undefined variables are used 
        and blocks a search for a user with an ID = null
        */
        if (typeof outbound.contact.activity_rates != "undefined") {

            _.defaults(outbound.contact.activity_rates, {
                user: null,
                rate: null,
                flat_rate: null
            });

            if ((outbound.contact.activity_rates.user === null) || (outbound.contact.activity_rates.rate === null) || (outbound.activity_rates.flat_rate === null)) {
                outbound.contact.activity_rates = [];
            } else {

                outbound.contact.activity_rates = [

                    {

                        user: {
                            id: outbound.contact.activity_rates.user
                        },

                        rate: outbound.contact.activity_rates.rate,

                        flat_rate: outbound.contact.activity_rates.flat_rate

                    }

                ];

            }
        }



        bundle.request.data = JSON.stringify(outbound);

        return bundle.request;


    },




    create_person_contact_pre_custom_action_fields: function (bundle) {



        //update the custom_field url to select the user chosen action field 

        bundle.request.url = bundle.request.url + "/" + bundle.action_fields.contact__custom_field_values__id;

        return bundle.request;
    },




    create_person_contact_post_custom_action_fields: function (bundle) {

        var result = JSON.parse(bundle.response.content);

        var type;

        // match Clio custom field with Zapier custom field

        switch (result.custom_field.field_type) {
        case "checkbox":
            type = "bool";
            break;
        case "time":
            type = "unicode";
            break;
        case "email":
            type = "unicode";
            break;
        case "numeric":
            type = "int";
            break;
        case "text_area":
            type = "text";
            break;
        case "currency":
            type = "int";
            break;
        case "date":
            type = "datetime";
            break;
        case "url":
            type = "unicode";
            break;
        case "text_line":
            type = "unicode";
            break;

        }




        return [{
            "type": type,
            "key": "contact__custom_field_values__value",
            "required": false,
            "label": JSON.stringify(result.custom_field.name),
            "help_text": "Enter a/an " + result.custom_field.field_type + " value"
        }]; // return fields in the order you want them displayed in the UI. They'll be appended after the regular action fields
    },




    create_person_contact_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);

        //Contact default values for phone_numbers,addresses,web_sites,instant_messengers

        _.defaults(outbound.contact, {

            phone_numbers: {
                name: null,
                number: null
            },
            addresses: {
                name: null,
                street: null,
                city: null,
                province: null,
                postal_code: null,
                country: null
            },
            web_sites: {
                name: null,
                address: null
            },
            instant_messengers: {
                name: null,
                address: null
            }


        });



        //Set contact type to Person

        outbound.contact.type = "Person";


        //Creating proper format for phone number entry

        outbound.contact.phone_numbers = [

            {
                name: outbound.contact.phone_numbers.name,
                number: outbound.contact.phone_numbers.number
            }

        ];

        //Creating proper format for email addresses entry

        /*
        Requires that an email address is present for there to be an 
        email_addresses entry
        */


        if (typeof outbound.contact.email_addresses != "undefined") {

            _.defaults(outbound.contact.email_addresses, {
                name: null,
                address: null
            });


            if (outbound.contact.email_addresses.address === null) {
                outbound.contact.email_addresses = [];
            } else {
                outbound.contact.email_addresses = [

                    {
                        name: outbound.contact.email_addresses.name,
                        address: outbound.contact.email_addresses.address
                    }

                ];

            }

        }

        //Creating proper format for addresses entry

        outbound.contact.addresses = [

            {
                name: outbound.contact.addresses.name,
                street: outbound.contact.addresses.street,
                city: outbound.contact.addresses.city,
                province: outbound.contact.addresses.province,
                postal_code: outbound.contact.addresses.postal_code,
                country: outbound.contact.addresses.country
            }

        ];

        //Creating proper format for websites entry



        outbound.contact.web_sites = [

            {
                name: outbound.contact.web_sites.name,
                address: outbound.contact.web_sites.address
            }

        ];

        //Creating proper format for instant messengers entry


        outbound.contact.instant_messengers = [

            {
                name: outbound.contact.instant_messengers.name,
                address: outbound.contact.instant_messengers.address
            }


        ];

        //Creating proper format for custom field entry

        /*
        Existential check for undefined variables and 
        stop custom_field searches with an ID = null
        */

        if (typeof outbound.contact.custom_field_values != "undefined") {


            _.defaults(outbound.contact.custom_field_values, {
                id: null,
                value: null
            });

            if ((outbound.contact.custom_field_values.id === null) || (outbound.contact.custom_field_values.value === null)) {
                outbound.contact.custom_field_values = [];
            } else {

                outbound.contact.custom_field_values = [

                    {

                        custom_field: {
                            id: outbound.contact.custom_field_values.id
                        },

                        value: outbound.contact.custom_field_values.value

                    }


                ];

            }
        }

        /*
         Existential check so that no undefined variables are used 
         and blocks a search for a user with an ID = null
         */
        if (typeof outbound.contact.activity_rates != "undefined") {

            _.defaults(outbound.contact.activity_rates, {
                user: null,
                rate: null,
                flat_rate: null
            });


            if ((outbound.contact.activity_rates.user === null) || (outbound.contact.activity_rates.rate === null) || (outbound.contact.activity_rates.flat_rate === null)) {
                outbound.contact.activity_rates = [];
            } else {

                outbound.contact.activity_rates = [

                    {

                        user: {
                            id: outbound.contact.activity_rates.user
                        },

                        rate: outbound.contact.activity_rates.rate,

                        flat_rate: outbound.contact.activity_rates.flat_rate

                    }

                ];

            }

        }


        bundle.request.data = JSON.stringify(outbound);

        return bundle.request;


    },




    create_task_pre_write: function (bundle) {

        var outbound = JSON.parse(bundle.request.data);

        //default reminder values
        _.defaults(outbound.task, {
            reminders: {
                unit: null,
                amount: null
            }
        });



        //Unit of time chosen

        var reminderTimeUnit = outbound.task.reminders.unit;

        //Amount of time

        var reminderAmount = outbound.task.reminders.amount;


        //Time conversion to minutes

        switch (reminderTimeUnit) {
        case "Hours":
            reminderAmount = reminderAmount * 60;
            break;
        case "Days":
            reminderAmount = reminderAmount * 1440;
            break;
        case "Weeks":
            reminderAmount = reminderAmount * 10080;
            break;
        }


        // entry into reminders list

        outbound.task.reminders = [

            {
                minutes: reminderAmount,

                method: "Popup"
            }

        ];


        bundle.request.data = JSON.stringify(outbound);

        return bundle.request;
    },

    
    
    
    make_get_request: function (bundle, url) {

        return JSON.parse(z.request(Zap.build_request(bundle, url, "GET", null)).content);

    },

    make_post_request: function (bundle, url, data) {

        return JSON.parse(z.request(Zap.build_request(bundle, url, "POST", data)).content);

    },



    
    build_request: function (bundle, url, method, data) {

        return {

            "url": url,
            "headers": {
                "Content-Type": "application/json; charset=utf-8",
                "Accept": "application/json",
                "Authorization": bundle.request.headers.Authorization
            },

            "method": method,
            "data": data
        };



    }



};