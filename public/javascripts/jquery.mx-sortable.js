/*
 * Saves a sortable set whenever you change it.
 */

(function ($) {
  $.fn.mx_sortable = function() {
    if (!this.length) {   return this; }
    return this.each(function() {
      var $this = $(this);
      var items = $this.data('sortableItems') || "li";
      var handle = $this.data('sortableHandle') || ".handle";
      $this.sortable({items:items, handle: handle}).bind( "sortupdate", function(event, ui) {
        var url = $this.data('sortableOnChangeUrl');
        if (url) {
          $this.css('opacity', 0.5);
          var serialized_data = $this.sortable("serialize");
          if (serialized_data) {
            $.post(url, serialized_data, function() {
              $this.css('opacity', 1.0);
            });
          }
        }
      });
    });
  };
})(jQuery);
