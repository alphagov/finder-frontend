window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  var $ = global.jQuery

  GOVUK.Modules.TrackBrexitQaChoices = function () {
    this.start = function (element) {
      track(element)
    }

    function track (element) {
      element.on('submit', function (event) {
        var $checkedOption, eventLabel, options
        var $submittedForm = $(event.target)
        var $checkedOptions = document.querySelectorAll('input:checked')
        var questionKey = $submittedForm.data('question-key')

        if ($checkedOptions) {
          console.log($checkedOptions[0])
          $checkedOptions.each(function (index) {
            $checkedOption = $(this)
            var checkedOptionId = $checkedOption.attr('id')
            var checkedOptionLabel = $submittedForm.find('label[for="' + checkedOptionId + '"]').text().trim()
            eventLabel = checkedOptionLabel.length
              ? checkedOptionLabel
              : $checkedOption.val()

            options = { transport: 'beacon', label: eventLabel }

            GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
          })
        } else {
          // Skipped questions
          options = { transport: 'beacon', label: 'no choice' }

          GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
        }
      })
    }
  }
})(window, window.GOVUK)
