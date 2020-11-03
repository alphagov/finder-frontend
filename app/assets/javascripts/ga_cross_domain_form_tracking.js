/* eslint-env jquery */
/* global ga */

function attachCrossDomainTrackerToInput (form, trackers) {
  if (trackers.length) {
    var existingAction = form.attr('action')
    var linker = new window.gaplugins.Linker(trackers[0])
    var trackedAction = linker.decorate(existingAction)
    form.attr('action', trackedAction)
  }
}

window.GOVUK = window.GOVUK || {}
var GOVUK = window.GOVUK
GOVUK.attachCrossDomainTrackerToInput = attachCrossDomainTrackerToInput

$(window).on('load', function () {
  if (window.ga !== undefined && typeof window.ga.getAll === 'function') {
    var trackers = ga.getAll()
    var form = $('form#account-signup')
    if (form.length) {
      window.GOVUK.attachCrossDomainTrackerToInput(form, trackers)
    }
  }
})
