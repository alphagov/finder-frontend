window.GOVUK = window.GOVUK || {};
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict';

  GOVUK.Modules.RemoveFilter = function () {
    var onChangeSuppressAnalytics = {
      type: "change",
      suppressAnalytics: true
    }

    this.start = function (element) {
      $(element).on('click', '[data-module="remove-filter-link"]', toggleFilter);
    };

    function toggleFilter(e) {
      e.preventDefault();
      e.stopPropagation();
      var $el = $(e.target);

      var removeFilterName = $el.data('name');
      var removeFilterValue = $el.data('value');
      var removeFilterLabel = $el.data('track-label');
      var removeFilterFacet = $el.data('facet');

      var $input = getInput(removeFilterName, removeFilterValue, removeFilterFacet);
      fireRemoveTagTrackingEvent(removeFilterLabel, removeFilterFacet);
      clearFacet($input, removeFilterValue, removeFilterFacet);
    }

    function clearFacet($input, removeFilterValue, removeFilterFacet) {
      var elementType = $input.prop('tagName');
      var inputType = $input.prop('type');
      var currentVal = $input.val();

      if (inputType == 'checkbox') {
        $input.prop("checked", false);
        $input.trigger(onChangeSuppressAnalytics);
      }
      else if (inputType == 'text' || inputType == 'search') {
        var splitKeywords = currentVal.split(" ");

        for (var i = 0; i < splitKeywords.length; i++) {
          if (splitKeywords[i].toString() === removeFilterValue.toString()) {
            splitKeywords.splice(i, 1);
            break;
          }
        }

        var newVal = splitKeywords.join(" ").trim();

        $input.val(newVal).trigger(onChangeSuppressAnalytics);
      }
      else if (elementType == 'OPTION') {
        $('#' + removeFilterFacet).val('').trigger(onChangeSuppressAnalytics);
      }
    }

    function getInput(removeFilterName, removeFilterValue, removeFilterFacet) {
      var selector = (!!removeFilterName) ? " input[name='" + removeFilterName + "']" : " [value='" + removeFilterValue + "']";

      return $('#' + removeFilterFacet).find(selector);
    }

    function fireRemoveTagTrackingEvent(filterValue, filterFacet) {
      var category = "facetTagRemoved";
      var action = filterFacet;
      var label = filterValue;

      GOVUK.analytics.trackEvent(
        category,
        action,
        { label: label }
      );
    }
  };
})(window, window.GOVUK);
