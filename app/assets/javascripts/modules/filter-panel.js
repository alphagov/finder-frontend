window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  class FilterPanel {
    constructor ($module) {
      this.$module = $module
    }

    init () {
      console.log('init:', this.$module)
    }
  }

  Modules.FilterPanel = FilterPanel
})(window.GOVUK.Modules)
