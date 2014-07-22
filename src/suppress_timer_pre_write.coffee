Zap.suppress_timer_pre_write = (bundle) ->
		#set API request method to "DELETE"
		bundle.request.method = "DELETE"
		#return bundle.request
		bundle.request
		