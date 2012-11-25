(function(jQuery) {
   
   function createInputText(name, size) {
     return '<input type="text" name="' + name + '" size=' + size + '>';
   };

   jQuery.fn.healthReportSettingAppender = function(options){
     var options = jQuery.extend({
       text: '',
       appendTo: ''
     }, options); 

     return this.each(function(i, elem) {
       jQuery(elem).click(function(e) {
         var k = createInputText("new_health_report_settings[][keyword]", 20);
         var u = createInputText("new_health_report_settings[][url_format]", 60);

         var text = options.text;
         text = text.replace('${keyword}', k);
         text = text.replace('${url_format}', u);

         var p = jQuery('<p>');
         p.append(text);

         jQuery(options.appendTo).append(p);

         e.preventDefault();
       });

     });
   };
})(jQuery);

