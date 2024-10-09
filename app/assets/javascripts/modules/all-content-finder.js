window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  // Enhances the all content finder with dynamic behaviour and analytics tracking
  class AllContentFinder {
    constructor ($module) {
      this.$module = $module
      this.$form = $module.querySelector('.js-all-content-finder-form')
    }

    init () {
    }
  }

  Modules.AllContentFinder = AllContentFinder
})(window.GOVUK.Modules)
