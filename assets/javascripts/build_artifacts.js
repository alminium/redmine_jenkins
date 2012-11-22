function BuildArtifacts(){};
BuildArtifacts.prototype = {
  initialize: function () {
     var targets = $$('img[class^="icon-build-artifacts"]');
     for (i=0; i<targets.length; i++) {
        $(document).on("click",
                       "img[class^=icon-build-artifacts]", 
                       this.show);
//   	Event.observe(targets[i], 'click', this.show.bindAsEventListener(this));
     }
     $(document).on("click",this.hide);
//     Event.observe(document, 'click', this.hide.bindAsEventListener(this) );
  },

  hide: function(e) {
    console.log(e);
        if ( Element.childOf(Event.element(e), 'build-artifacts')) {
        if ( Event.element(e).tagName == 'A' ) { return; }
        if ( Event.element(e).tagName == 'IMG' ) { return; }
    }
    $("#build-artifacts").hide();
//    Element.hide('build-artifacts');
  },

  show: function(e) {
    console.log(e);  
    Element.update('build-artifacts-list', '');
    $("#build-artifacts").html("");
    $("#build-artifacts").hide();    
//    Element.hide('build-artifacts');

    elmTarget = Event.element(e);
    name = elmTarget.id.substring("build-artifacts-".length, elmTarget.id.length);

    list_name = "#build-artifacts-list-" + name;

    dialog = $('#build-artifacts');
    dialog.style.top = (elmTarget.positionedOffset().top + Element.getHeight(elmTarget) + 5 ) + 'px';
    dialog.style.left = (elmTarget.positionedOffset().left + 2) + 'px';
    //Element.update('build-artifacts', list_name);

    $("#build-artifacts").html($("#list_name"));
    Element.update('build-artifacts-list', $(list_name).innerHTML);
    $("#build-artifacts").show();
    if (window.parseStylesheets) { window.parseStylesheets(); } // IE
  }
}
