function fetch_data(url, callback) {
        var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function(data) {
      if (xhr.readyState == 4) {
        if (xhr.status == 200) {
          var data = xhr.responseText;
          console.log("in background, :" + data)
          callback(data);
        } else {
          callback(null);
        }
      }
    }
    // Note that any URL fetched here must be matched by a permission in
    // the manifest.json file!
    xhr.open('GET', url, true);
    xhr.send();
}

function onRequest(request, sender, callback) {
        if (request.action == 'fetch_data') {
         fetch_data(request.url, callback);
       }
}

// Wire up the listener.
chrome.extension.onRequest.addListener(onRequest);