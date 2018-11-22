window.GOVUK = window.GOVUK || {};
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict';

  GOVUK.Modules.RemoveFilter = function () {
    this.start = function (element) {
      $(element).on('click', '[data-module="remove-filter-link"]', toggleFilter);
    };

    function toggleFilter(e) {
      e.preventDefault();

      var selector = "";
      var name = $(this).data("name");

      if (!!name) {
          selector +=  " :input[name='" + name + "']";
      } else {
          var value = $(this).data("value");
          selector += " [value='" + value + "']";
      }

      var facet = $(this).data("facet");
      var $elem = $("#" + facet).find(selector);

      var elementType = $elem.prop('tagName');
      var inputType = $elem.prop('type');

      if (inputType == "checkbox"){
        $elem.trigger("click");
      }
      else if (elementType == "INPUT") {
        $elem.val("").trigger("change");
      }
      else if (elementType == "OPTION") {
        $('#' + facet).val("").trigger("change");
      }
    };
  }
})(window, window.GOVUK);
