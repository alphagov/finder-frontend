window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  GOVUK.Modules.TrackBrexitQaChoices = function () {
    this.start = function (element) {
      track(element)
    }

    function track (element) {
      element.on('submit', function (event) {
        var eventLabel, options
        var submittedForm = event.target
        var $checkedOptions = submittedForm.querySelectorAll('input:checked')
        var questionKey = submittedForm.dataset.questionKey

        if ($checkedOptions) {
          for (var i = 0; i < $checkedOptions.length; i++) {
            var checkedOptionId = $checkedOptions[i].getAttribute('id')
            var checkedOptionLabelText = submittedForm.querySelector('label[for="' + checkedOptionId + '"]')
            var someText = checkedOptionLabelText.textContent || checkedOptionLabelText.innerText
            var checkedOptionLabel = someText.replace(/^\s+|\s+$/g, '')
            eventLabel = checkedOptionLabel.length
              ? checkedOptionLabel
              : $checkedOptions[i].value

            options = { transport: 'beacon', label: eventLabel }
            GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
          }
        } else {
          // Skipped questions
          options = { transport: 'beacon', label: 'no choice' }

          GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
        }
      })
    }
  }
})(window, window.GOVUK)
