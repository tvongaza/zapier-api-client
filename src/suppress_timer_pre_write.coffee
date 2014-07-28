Zap.suppress_timer_pre_write = (bundle) ->
  #set clio api request method to DELETE
  bundle.request.method = "DELETE"
  #return bundle.request
  bundle.request
	
		