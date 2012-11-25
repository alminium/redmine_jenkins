(function(jQuery) {

   function setDisplay(elem, state){
    var display = 'none';
    if (state) { display = 'inline'; }
    elem.attr('style', 'display:' + display);
   };
   
   jQuery.fn.displaySwitcher = function(options){
     var options = jQuery.extend({ 
       target: '',
       initialState: true
     }, options);
     
     return this.each(function(i, elem) {
       jQuery(elem).click(function() {
         setDisplay(jQuery(options.target), jQuery(this).attr('checked'));
       });

       jQuery(elem).attr('checked', options.initialState);
       setDisplay(jQuery(options.target), jQuery(elem).attr('checked'));
     });
   };
})(jQuery);

