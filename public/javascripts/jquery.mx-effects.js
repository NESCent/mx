/*
 */

(function ($) {
  $.fn.mx_effect = function(type, options) {
    if (!this.length) {   return this; }
    return this.each(function() {
      switch (type) {
        case 'fade':
        $(this).fadeOut(200);
        break;
        case 'error_shake':
        $(this).effect("shake", {times: 3 }, 50);
        break;
      }
    });
  };
})(jQuery);
