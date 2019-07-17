window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  var $ = global.jQuery

  GOVUK.Modules.TrackQaChoices = function () {
    this.start = function (element) {
      track(element)
    }

    function track (element) {
      element.on('submit', function (event) {
        var $checkedOption, eventLabel, options
        var $submittedForm = $(event.target)
        var $checkedOptions = $submittedForm.find('input:checked')

        $checkedOptions.each(function (index) {
          $checkedOption = $(this)
          eventLabel = $checkedOption.attr('name').replace('[]', '')
          options = { transport: 'beacon', label: eventLabel }

          GOVUK.SearchAnalytics.trackEvent('QA option chosen', $checkedOption.val(), options)
        })
      })
    }
  }
})(window, window.GOVUK)
