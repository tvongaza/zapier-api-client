Zap.make_get_request =  (bundle, url) ->
    JSON.parse z.request(Zap.build_request(bundle, url, "GET", null)).content
