Zap.create_timer_pre_write = (bundle)->
		outbound = JSON.parse(bundle.request.data)
		#create timer instance
		outbound = timer:
			activity:
				id: outbound.timer.activity.id
		#set bundle.request.data to outbound
		bundle.request.data = JSON.stringify(outbound)
		#return bundle.request
		bundle.request
  