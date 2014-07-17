Zap.new_task_post_poll = (bundle) ->
    results = JSON.parse(bundle.response.content)
    
    #reverse task array for reverse-chronological order
    results.tasks.reverse()