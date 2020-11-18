/* eslint-env jquery */
/* global ga */

(function(Modules) {
  'use strict'

  function AttachCrossDomainTrackerToInput () {}
  AttachCrossDomainTrackerToInput.prototype.start = function($form) {
    console.log("Object", window.ga)
    console.log("undefined test", window.ga !== undefined)
    console.log("getAll is a function", typeof window.ga.getAll === 'function')
    if (window.ga !== undefined && typeof window.ga.getAll === 'function') {
      console.log(window.ga.getAll())
      var trackers = window.ga.getAll()
      if (trackers.length) {
        var existingAction = $form.attr('action')
        var linker = new window.gaplugins.Linker(trackers[0])
        var trackedAction = linker.decorate(existingAction)
        $form.attr('action', trackedAction)
      }
    }
  }
  Modules.AttachCrossDomainTrackerToInput = AttachCrossDomainTrackerToInput
})(window.GOVUK.Modules)
