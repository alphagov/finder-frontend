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

      var removeFilterName = $(this).data("name");
      var removeFilterValue = $(this).data("value");
      var removeFilterFacet = $(this).data("facet");

      var inputSelector = getSelectorForInput(removeFilterName, removeFilterValue);
      var $input = $("#" + removeFilterFacet).find(inputSelector);

      var elementType = $input.prop('tagName');
      var inputType = $input.prop('type');

      setInputState(elementType, inputType, $input);
    }

    function setInputState(elementType, inputType, $input) {
      if (inputType == "checkbox"){
        $input.trigger("click");
      }
      else if (inputType == "text") {
        var currentVal = $input.val();
        var newVal = $.trim(currentVal.replace(value, ''));

        $input.val(newVal).trigger("change");
      }
      else if (elementType == "INPUT") {
        $input.val("").trigger("change");
      }
      else if (elementType == "OPTION") {
        $('#' + facet).val("").trigger("change");
      }
    };

    function getSelectorForInput(removeFilterName, removeFilterValue) {
      if (!!removeFilterName) {
        return " :input[name='" + removeFilterName + "']";
      } else {
        return " [value='" + removeFilterValue + "']";
      }
    }
  }
})(window, window.GOVUK);
