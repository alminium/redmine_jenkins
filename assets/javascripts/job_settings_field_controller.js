/* $Id$ */

JobSettingsFieldController = Class.create();
JobSettingsFieldController.prototype = {
  initialize: function () {
    this.elements_build_rotate = $$('input[class^="build_rotate"]');
    for (i=0; i<this.elements_build_rotate.length; i++) {
      Event.observe(this.elements_build_rotate[i], 'click', this.build_rotate_clicked.bindAsEventListener(this));
      this.change_disabled(this.elements_build_rotate[i]);
    }
  },

  build_rotate_clicked: function(e) {
    elem_rotate = Event.element(e);
    this.change_disabled(elem_rotate);
  },

  change_disabled: function(elem_rotate) {
    id_base = elem_rotate.id.substring(0, elem_rotate.id.length - "_build_rotate".length);

    disabled = !elem_rotate.checked;
    $(id_base + "_build_rotator_days_to_keep").disabled = disabled;
    $(id_base + "_build_rotator_num_to_keep").disabled = disabled;
  }

}
