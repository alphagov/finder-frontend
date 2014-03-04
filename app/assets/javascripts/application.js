// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

(function($) {
  // TODO: Where does this go aaaaagh
  "use strict";

  var enableDocumentFilter = function(){
    this.each(function(){
      var $facet = $(this),
          $clearLink = $facet.find('.clear-selected');

      $('.js-openable-facet .head').on('click', function(){
        $(this).parent().toggleClass('open');
      });

      $clearLink.on('click', function(e){
        $("input[type='checkbox']", $facet).prop({
          indeterminate: false,
          "checked": false
        });
        $(this).addClass('js-hidden');
        return false;
      });

      $('.js-openable-facet input[type="checkbox"]').on('click', function(){
        var checked = $(this).prop("checked"),
            container = $(this).parent(),
            siblings = container.siblings();

        container.find('input[type="checkbox"]').prop({
          indeterminate: false,
          checked: checked
        });

        /* Show / hide clear link */
        function updateClearVisibility(el){
          var anyCheckedBoxes = $("input[type='checkbox']", $facet).is(":checked"),
              clearLinkHidden = $clearLink.hasClass('js-hidden')

          if (anyCheckedBoxes && clearLinkHidden) {
            $clearLink.removeClass('js-hidden');
          } else if (!anyCheckedBoxes && !clearLinkHidden) {
            $clearLink.addClass('js-hidden');
          }
        }

        /* Make nested checkboxes influence parents */
        function checkSiblings(el) {
          var parent = el.parent(),
          all = true;
          el.siblings().each(function() {
            return all = ($(this).children('input[type="checkbox"]').prop("checked") === checked);
          });

          if (all && checked) {
            parent.children('input[type="checkbox"]').prop({
              indeterminate: false,
              checked: checked
            });
            checkSiblings(parent);
          } else if (all && !checked) {
            parent.children('input[type="checkbox"]').prop("checked", checked);
            parent.children('input[type="checkbox"]').prop("indeterminate", (parent.find('input[type="checkbox"]:checked').length > 0));
            checkSiblings(parent);
          } else {
            el.parents("li").children('input[type="checkbox"]').prop({
              indeterminate: true,
              checked: false
            });
          }
        }
        updateClearVisibility(container);
        checkSiblings(container);
      });

    });
    return this
  }

  $.fn.extend({
    enableDocumentFilter: enableDocumentFilter
  });

})(jQuery);



jQuery(function($) {
  $(document).ready(function(){
    $(".facet-menu").enableDocumentFilter();
  })
});
