/* $Id$ */

DescriptionVisibilityController = Class.create();
DescriptionVisibilityController.prototype = {
  initialize: function (first_state, label_show, label_hide) {
     this.label_show = label_show;
     this.label_hide = label_hide;
     this.elements_description = $$('div[class^="wiki job-description"]');
     this.elements_health_reports = $$('ul[class^="job-health-reports"]');
     this.button = $('switch-description-visibility');

     if ( first_state ) {
        this.show();
     } else {
        this.hide();
     }

     Event.observe(this.button, 'click', this.switch_state.bindAsEventListener(this));
  },

  switch_state: function() {
    if ( this.visibility ) {
      this.hide();
    } else {
      this.show();
    }
  },

  show: function() {
    this.visibility = true;
    Element.update(this.button, this.label_hide);
    showElements(this.elements_description);
    showElements(this.elements_health_reports);
  },

  hide: function() {
    this.visibility = false;
    Element.update(this.button, this.label_show);
    hideElements(this.elements_description);
    hideElements(this.elements_health_reports);
  }
}

function showElements(elements) {
  for (i=0; i<elements.length; i++) {
    Element.show(elements[i]);
  }
}

function hideElements(elements) {
  for (i=0; i<elements.length; i++) {
    Element.hide(elements[i]);
  }
}
