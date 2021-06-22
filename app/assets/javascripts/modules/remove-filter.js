window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  GOVUK.Modules.RemoveFilter = function RemoveFilter () {
    this.start = function (element) {
      $(element).on('click', '[data-module="remove-filter-link"]', toggleFilter)
    }

    function toggleFilter (e) {
      e.preventDefault()
      e.stopPropagation()
      var $el = $(e.target)

      var removeFilterName = $el.data('name')
      var removeFilterValue = $el.data('value')
      var removeFilterLabel = $el.data('track-label')
      var removeFilterFacet = $el.data('facet')

      var $input = getInput(removeFilterName, removeFilterValue, removeFilterFacet)
      fireRemoveTagTrackingEvent(removeFilterLabel, removeFilterFacet)
      clearFacet($input, removeFilterValue, removeFilterFacet)
    }

    function clearFacet ($input, removeFilterValue, removeFilterFacet) {
      var elementType = $input.prop('tagName')
      var inputType = $input.prop('type')
      var currentVal = $input.val()

      if (inputType === 'checkbox') {
        $input.prop('checked', false)
        window.GOVUK.triggerEvent($input[0], 'change', { detail: { suppressAnalytics: true } })
      } else if (inputType === 'text' || inputType === 'search') {
        /* By padding the haystack with spaces, we can remove the
         * first instance of " $needle ", and this will catch it in
         * the middle of the haystack, at the ends, and when the
         * needle is the haystack; without needing to consider these
         * boundary conditions explicitly.
         *
         * The only caveat is that the matched needle needs replacing
         * with " ", to avoid merging adjacent keywords when it was in
         * the middle of the string, eg:
         *
         * needle = "beta"
         * haystack = "alpha beta gamma"
         *
         * Just removing " beta " from the haystack would result in
         * "alphagamma", which is wrong.
         */
        var haystack = ' ' + currentVal.trim() + ' '
        var needle = ' ' + decodeEntities(removeFilterValue.toString()) + ' '
        var newVal = haystack.replace(needle, ' ').replace(/ {2}/g, ' ').trim()
        window.GOVUK.triggerEvent($input.val(newVal)[0], 'change', { detail: { suppressAnalytics: true } })
      } else if (elementType === 'OPTION') {
        window.GOVUK.triggerEvent($('#' + removeFilterFacet).val('')[0], 'change', { detail: { suppressAnalytics: true } })
      }
    }

    function getInput (removeFilterName, removeFilterValue, removeFilterFacet) {
      var selector = (removeFilterName) ? " input[name='" + removeFilterName + "']" : " [value='" + removeFilterValue + "']"

      return $('#' + removeFilterFacet).find(selector)
    }

    function fireRemoveTagTrackingEvent (filterValue, filterFacet) {
      var category = 'facetTagRemoved'
      var action = filterFacet
      var label = filterValue

      GOVUK.SearchAnalytics.trackEvent(
        category,
        action,
        { label: label }
      )

      GOVUK.SearchAnalytics.trackEvent(
        category,
        action,
        { label: label, trackerName: 'govuk' }
      )
    }

    function decodeEntities (string) {
      return string
        .replace(/&quot;/g, '"')
    }
  }
})(window, window.GOVUK)
