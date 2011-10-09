// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function initialize_js(root) {
  var $root = $(root);
  var find = function(expr){
    return $($root).is(expr) ? $(expr, $root).add($root) : $(expr, $root);
  };
  find('.mx-autocomplete').mx_autocompleter();
  find("a[data-ajaxify], input[data-ajaxify]").ajaxify();
  find("input[data-color-picker]").mx_color_picker();
  find("*[data-insert-content]").mx_insert_content();
  find("*[data-sortable]").mx_sortable();
  find("*[data-tooltip]").mx_tooltip();

}
//
$(document).ready(function(){
  initialize_js($("body"));
  $('body').mx_flash();

  // Attach to the mx_spinner -- any link-to-remotes will trigger this spinner effect.
  $("form[data-remote],a[data-remote],input[data-remote]")
    .bind('ajax:before', function() {
      $('body').mx_spinner('show');
    })
    .bind('ajax:complete', function() {
      $('body').mx_spinner('hide');
    });
});
