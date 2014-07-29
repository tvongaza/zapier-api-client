Zap.make_delete_request = (bundle,url,data)->
    JSON.parse z.request(Zap.build_request(bundle, url, "DELETE", data)).content
