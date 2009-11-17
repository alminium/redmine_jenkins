/* $Id$ */
BuildRequest = Class.create();
BuildRequest.prototype = {
  initialize: function (url, message_success, message_failure) {
    this.url = url;
    this.message_success = message_success;
    this.message_failure = message_failure;
    var latestBuilds = $$('img[class^="icon-build-request"]');
    for (i=0; i<latestBuilds.length; i++) {
      Event.observe(latestBuilds[i], 'click', this.request.bindAsEventListener(this));
    }
  },
  request: function(e) {
    Element.update('info', '');
    Element.hide('info');

    Element.update('error', '');
    Element.hide('error');

    elmBuildHistory = Event.element(e);
    name = elmBuildHistory.id.substring("build-request-".length, elmBuildHistory.id.length);
    message_success = this.message_success;
    message_failure = this.message_failure

    new Ajax.Updater({success:'remote-debug', failuer:'remote-debug'}, this.url,
      {asynchronous:true,
       evalScripts:true,
       parameters:"name=" + name,
       method:'get',
       onComplete:function(request){
         var message = "";
         if( request.responseText.indexOf('build_accepted') > 0 ) {
           message = message_success.replace('${job_name}', name);
           show_build_request_result('info', message);
         } else {
           message = message_failure.replace('${job_name}', name);
           message = message + '<br>' + request.responseText;
           show_build_request_result('error', message);
         }
       },
       onFailure:function(httpObj){
         var message = message_failure.replace('${job_name}', name)
         message = message + "<br>http-status : " + httpObj.status;
         show_build_request_result('error', message, name);
       }})
  }
}

function show_build_request_result(id, message) {
  Element.update(id, message);
  Element.show(id);
  Effect.ScrollTo(id);
}


