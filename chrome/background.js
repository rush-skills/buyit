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


chrome.tabs.onUpdated.addListener(function(activeInfo) {
  reset_data();
});
chrome.tabs.onActivated.addListener(function(tabId, changeInfo, updatedTab) {
  reset_data();
});


function reset_data() {
  chrome.tabs.getSelected(null,function(tab){
    url=tab.url.replace(/https?:\/\//i, "").split('#')[0];
    if(url.indexOf("snapdeal") > -1){
      fetch_url = 'http://localhost:3456/' + url;
      console.log("in reset_Data of background: "+ fetch_url);
      fetch_data(fetch_url);
    }
    else{
      chrome.browserAction.setIcon(
      {
        path: "icon.png"
      });
    }
  });
}

function fetch_data(url) {
  console.log("in fetch_Data of back");
  var xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function(data) {
    if (xhr.readyState == 4) {
      if (xhr.status == 200) {
        var data = xhr.responseText;
        console.log("in background, :" + data)
        set_data(data);
      } else {
        set_data(null);
      }
    }
  }
  // Note that any URL fetched here must be matched by a permission in
  // the manifest.json file!
  xhr.open('GET', url, true);
  xhr.send();
}

function set_data(response){
  number = parseInt(response,10);
  console.log("number = "+number);
  console.log("response = "+response);
  if(number == 0){
    chrome.browserAction.setIcon(
      {
        path: "thumbsdown.png"
      });
  }
  else if(number == 1){
    chrome.browserAction.setIcon(
      {
        path: "neutral.png"
      });
  }
  else if(number == 2){
    chrome.browserAction.setIcon(
      {
        path: "thumbsup.png"
      });
  }
  else{
    chrome.browserAction.setIcon(
      {
        path: "icon.png"
      });
  }
  console.log(response);
}
