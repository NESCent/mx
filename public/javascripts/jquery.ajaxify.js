(function($) {
  var Ajaxify = {
    eval_html: function(html) {
      var exec_wrap = $("<div style='display:none'></div>");
      $('body').append(exec_wrap);
      exec_wrap.html(html);
      exec_wrap.remove();
    },

    request: function(element, options) {
      var $element = $(element);
      var $form = null;
      opts = {};

      if ($element.attr('href'))
      {
        opts.url = $element.attr('href');
        opts.data = {};
        $form = $element;
        opts.type = $element.data('ajaxifyMethod') || 'GET';
      }
      else
      {
        if($element.get(0).nodeName.toLowerCase() == 'input' &&
           $element.prop('type').toLowerCase() == 'submit')
        {
          $form = $element.parents("form");

          // Emulate the button being pressed, by adding it's name/value to the request
          var button_input = $("<input type='hidden' name='"+$element.attr('name')+"' " +
                               "value='"+$element.attr('value')+"'></input>");

          $form.append(button_input);
          opts.data = $form.serialize();
          button_input.remove();
        } else
        {

          if($element.get(0).nodeName.toLowerCase() == 'form'){
            $form = $element;
          }else{
            $form = $element.parents("form");
          }
          opts.data = $form.serialize();
        }

        opts.url  = $form.attr('action');
        opts.type = $form.attr('method');
      }

      var combo_options = $.extend({}, opts, options);

      combo_options.success = function(xhr, status) {
        $form.trigger('ajaxify:success', {xhr: xhr, status:status, form: $form});
        if (options.success) { options.success(xhr, status); }
      };

      combo_options.error = function(xhr, status) {
        $form.trigger('ajaxify:error', {xhr: xhr, status:status, form: $form});
        if (options.error) { options.error(xhr, status);}
      };

      combo_options.complete = function(xhr, status) {
        $form.trigger('ajaxify:complete', {xhr: xhr, status:status, form: $form});
        if (options.complete) { options.complete(xhr, status);}
      };

      $form.trigger('ajax:start');

      $.ajax(combo_options);
    }
  };
  var options = {
  };


  $.fn.ajaxify = function(options) {
    var handlers = {
      submit: function($e, options) {
        $e.click(function(evt) {
          var request_options = $.extend({}, options, {
            dataType: 'script html',
            complete: function(xhr, status) {
              eval_html(xhr.responseText);
            }
          });
          Ajaxify.request($e, request_options);
          evt.preventDefault();
        });
      },
      modal: function($e, options){
        $e.click(function(evt) {
          $.basicModal('loading');

          var request_opts = $.extend({}, options, {
            dataType: 'script html',
            complete: function(xhr, status) {
              $.basicModal('show', xhr.responseText);
            }
          });

          Ajaxify.request($e, request_opts);
          evt.preventDefault();
        });
      }
    };

    if (!this.length) {   return this; }

    return this.each(function() {
      var $this = $(this);
      var handler_options = {};
      handlers[$this.data('ajaxify')]($this);
    });
  };
})(jQuery);
