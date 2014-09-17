Zap.make_get_request =  (bundle, url) ->
  content = z.request(Zap.build_request(bundle, url, "GET", null)).content
  JSON.parse content