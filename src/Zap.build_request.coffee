build_request: (bundle, url, method, data) ->
    url: url
    headers:
      "Content-Type": "application/json; charset=utf-8"
      Accept: "application/json"
      Authorization: bundle.request.headers.Authorization

    method: method
    data: data
