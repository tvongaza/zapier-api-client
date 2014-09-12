Zap.make_get_request =  (bundle, url) ->
  # console.log(url)
  content = z.request(Zap.build_request(bundle, url, "GET", null)).content
  JSON.parse content
