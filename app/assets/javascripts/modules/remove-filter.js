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

      var removeFilterName = $(this).data('name');
      var removeFilterValue = $(this).data('value');
      var removeFilterFacet = $(this).data('facet');
      var removeFilterAutocomplete = !!$('#' + removeFilterFacet +'__listbox').length;
      
      var $input = getInput(removeFilterName, removeFilterValue, removeFilterFacet, removeFilterAutocomplete);

      var elementType = $input.prop('tagName');
      var inputType = $input.prop('type');

      setInputState(elementType, inputType, $input, removeFilterValue, removeFilterFacet, removeFilterAutocomplete);
    }

    function setInputState(elementType, inputType, $input, removeFilterValue, removeFilterFacet, removeFilterAutocomplete) {
      if (inputType == 'checkbox') {
        $input.prop("checked", false);
        $input.trigger('change');
      }
      else if (inputType == 'text' || inputType == 'search') {
        var currentVal = $input.val();
        var valToReplace = removeFilterAutocomplete ? currentVal : removeFilterValue;
        var newVal = $.trim(currentVal.replace(valToReplace, ''));

        $input.val(newVal).trigger('change');
      }
      else if (elementType == 'OPTION') {
        $('#' + removeFilterFacet).val("").trigger('change');
      }
    };

    function getInput(removeFilterName, removeFilterValue, removeFilterFacet, removeFilterAutocomplete) {
      var selector = (!!removeFilterName) ? " input[name='" + removeFilterName + "']" : " [value='" + removeFilterValue + "']";

      if (removeFilterAutocomplete) {
        return $('#' + removeFilterFacet);
      }
      else {
        return $('#' + removeFilterFacet).find(selector);
      }
    }
  }
})(window, window.GOVUK);
