function BuildRequest(url, message_success, message_failure) {
  this.initialize(url, message_success, message_failure);
};

BuildRequest.prototype = {
  initialize: function (url, message_success, message_failure) {
    console.log("initialize");
    var latestBuilds = $('img[class="icon-build-request"]');
    latestBuilds.on("click", {
        url: url,
        message_success: message_success,
        message_failure: message_failure
      },
      this.request);
  },
  request: function(e) {
    $("#info").html('');
    $("#info").hide();

    $("#error").html('');
    $("#error").hide();
    
    name = e.target.id.substring("build-request-".length, e.target.id.length);
    $.ajax({
      type: "GET",
      url: e.data.url,
      data: "name=" + name,
      success: function(request){
         console.log(this);
         console.log(request);
         var message = "";
         if( request.indexOf('build_accepted') > 0 ) {
           console.log(e.data.message_success);
           message = e.data.message_success.replace('${job_name}', name);
           show_build_request_result('#info', message);
         } else {
           console.log(e.data.message_failure);
           message = e.data.message_failure.replace('${job_name}', name);
           message = message + '<br>' + request.responseText;
           show_build_request_result('#error', message);
         }
      },
      error: function(message_failure){
         console.log(this);      
         console.log(messsage_failure);
         var message = message_failure.replace('${job_name}', name)
         message = message + "<br>http-status : " + httpObj.status;
         show_build_request_result('#error', message, name);
      }
    });
  }
}

function show_build_request_result(id, message) {
  $(id).html(message);
  $(id).show();
}


