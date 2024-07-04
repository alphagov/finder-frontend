window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function RemoveFilter (element) {
    this.element = element
  }

  RemoveFilter.prototype.init = function () {
    this.element.addEventListener('click', function (e) {
      if (e.target.getAttribute('data-module') === 'remove-filter-link') {
        this.toggleFilterHandler(e)
      }
    }.bind(this))
  }

  RemoveFilter.prototype.toggleFilterHandler = function (e) {
    e.preventDefault()
    e.stopPropagation()
    var $el = e.target

    var removeFilterName = $el.getAttribute('data-name')
    var removeFilterValue = $el.getAttribute('data-value')
    var removeFilterFacet = $el.getAttribute('data-facet')

    var $input = this.getInput(removeFilterName, removeFilterValue, removeFilterFacet)
    this.clearFacet($input, removeFilterValue, removeFilterFacet)
  }

  RemoveFilter.prototype.clearFacet = function ($input, removeFilterValue, removeFilterFacet) {
    var elementType = $input.tagName
    var inputType = $input.type
    var currentVal = $input.value

    if (inputType === 'checkbox') {
      $input.checked = false
      window.GOVUK.triggerEvent($input, 'change', { detail: { suppressAnalytics: true } })
    } else if (inputType === 'text' || inputType === 'search' || inputType === 'hidden') {
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
      var needle = ' ' + this.decodeEntities(removeFilterValue.toString()) + ' '
      var newVal = haystack.replace(needle, ' ').replace(/ {2}/g, ' ').trim()
      $input.value = newVal
      window.GOVUK.triggerEvent($input, 'change', { detail: { suppressAnalytics: true } })
    } else if (elementType === 'OPTION') {
      var element = document.getElementById(removeFilterFacet)
      element.value = ''
      window.GOVUK.triggerEvent(element, 'change', { detail: { suppressAnalytics: true } })
    }
  }

  RemoveFilter.prototype.getInput = function (removeFilterName, removeFilterValue, removeFilterFacet) {
    var selector = (removeFilterName) ? "input[name='" + removeFilterName + "']" : "[value='" + removeFilterValue + "']"
    var element = document.getElementById(removeFilterFacet)

    return element.querySelector(selector)
  }

  RemoveFilter.prototype.decodeEntities = function (string) {
    return string
      .replace(/&quot;/g, '"')
  }

  Modules.RemoveFilter = RemoveFilter
})(window.GOVUK.Modules)
