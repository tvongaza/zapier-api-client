Zap.new_bill_post_poll = (bundle)->
	results = JSON.parse(bundle.response.content)
	array=[]
	#loop through results to re-format for Zapier
	for field in results.bills
		#populate array
		array.push
			id:field.id
			number:field.number
			subject:field.subject
			currency:field.currency
			purchase_order:field.purchase_order
			memo:field.memo
			start_at:field.start_at
			end_at:field.end_at
			issued_at:field.issued_at
			due_at:field.due_at
			type:field.type
			original_bill_id:field.original_bill_id
			tax_rate:field.tax_rate
			secondary_tax_rate:field.secondary_tax_rate
			discount:field.discount
			discount_type:field.discount_type
			discount_note:field.discount_note
			balance:field.balance
			balance_with_interest:field.balance_with_interest
			total:field.total
			status:field.status
			state:field.state
			matter_id:field.matters[0].id
			matter_name:field.matters[0].name
			client_id:field.client.id
			client_name:field.client.name
	#return array
	array
		