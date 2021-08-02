window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function TrackBrexitQaChoices (element) {
    this.element = element
  }

  TrackBrexitQaChoices.prototype.init = function () {
    this.element.addEventListener('submit', this.submitHandler.bind(this))
  }

  TrackBrexitQaChoices.prototype.submitHandler = function () {
    var eventLabel, options
    var checkedOptions = this.element.querySelectorAll('input:checked')
    var questionKey = this.element.getAttribute('data-question-key')

    if (checkedOptions.length) {
      for (var i = 0; i < checkedOptions.length; i++) {
        var checkedOptionId = checkedOptions[i].getAttribute('id')
        var checkedOptionLabelText = this.element.querySelector('label[for="' + checkedOptionId + '"]')
        var checkedOptionLabel = ''

        if (checkedOptionLabelText != null) {
          checkedOptionLabel = checkedOptionLabelText.textContent.replace(/^\s+|\s+$/g, '')
        }

        eventLabel = checkedOptionLabel.length
          ? checkedOptionLabel
          : checkedOptions[i].value

        options = { transport: 'beacon', label: eventLabel }

        GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
      }
    } else {
      // Skipped questions
      options = { transport: 'beacon', label: 'no choice' }

      GOVUK.SearchAnalytics.trackEvent('brexit-checker-qa', questionKey, options)
    }
  }

  Modules.TrackBrexitQaChoices = TrackBrexitQaChoices
})(window.GOVUK.Modules)
