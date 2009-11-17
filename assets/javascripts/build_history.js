/* $Id$ */

BuildHistory = Class.create();
BuildHistory.prototype = {
  initialize: function (url) {
     this.url = url;
	 var latestBuilds = $$('img[class^="icon-build-history"]');
	 for (i=0; i<latestBuilds.length; i++) {
   		Event.observe(latestBuilds[i], 'click', this.show.bindAsEventListener(this));
	 }
     Event.observe(document, 'click', this.hide.bindAsEventListener(this) );
  },

  hide: function(e) {
    if ( Element.childOf(Event.element(e), 'build-history')) {
        if ( Event.element(e).tagName == 'A' ) { return; }
        if ( Event.element(e).tagName == 'IMG' ) { return; }
    }
    Element.hide('build-history');
  },

  show: function(e) {
    Element.update('build-history', '');
    Element.hide('build-history');

    elmBuildHistory = Event.element(e);
    name = elmBuildHistory.id.substring("build-history-".length, elmBuildHistory.id.length);

    new Ajax.Updater({success:'build-history', failuer:'build-history'}, this.url,
      {asynchronous:true,
       evalScripts:true,
       parameters:"name=" + name,
       method:'get',
       onComplete:function(request){
         dialog = $('build-history');
         dialog.style.top = (elmBuildHistory.positionedOffset().top + Element.getHeight(elmBuildHistory) + 5 ) + 'px';
         dialog.style.left = (elmBuildHistory.positionedOffset().left + 2) + 'px';
         Effect.Appear('build-history');
         if (window.parseStylesheets) { window.parseStylesheets(); } // IE
      },
      onFailure:function(httpObj){
         Element.update('build-history', "Can't get build history. http-status : " + httpObj.status);
         Effect.Appear('build-history');
      }})
  }
}
