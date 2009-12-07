/* $Id$ */

BuildArtifacts = Class.create();
BuildArtifacts.prototype = {
  initialize: function () {
     var targets = $$('img[class^="icon-build-artifacts"]');
     for (i=0; i<targets.length; i++) {
   	Event.observe(targets[i], 'click', this.show.bindAsEventListener(this));
     }
     Event.observe(document, 'click', this.hide.bindAsEventListener(this) );
  },

  hide: function(e) {
    if ( Element.childOf(Event.element(e), 'build-artifacts')) {
        if ( Event.element(e).tagName == 'A' ) { return; }
        if ( Event.element(e).tagName == 'IMG' ) { return; }
    }
    Element.hide('build-artifacts');
  },

  show: function(e) {
    Element.update('build-artifacts-list', '');
    Element.hide('build-artifacts');

    elmTarget = Event.element(e);
    name = elmTarget.id.substring("build-artifacts-".length, elmTarget.id.length);

    list_name = "build-artifacts-list-" + name;

    dialog = $('build-artifacts');
    dialog.style.top = (elmTarget.positionedOffset().top + Element.getHeight(elmTarget) + 5 ) + 'px';
    dialog.style.left = (elmTarget.positionedOffset().left + 2) + 'px';
    //Element.update('build-artifacts', list_name);

    Element.update('build-artifacts-list', $(list_name).innerHTML);
    Effect.Appear('build-artifacts');
    if (window.parseStylesheets) { window.parseStylesheets(); } // IE
  }
}
