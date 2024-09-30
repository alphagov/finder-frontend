window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  class FilterSection {
    constructor ($module) {
      this.$module = $module
      this.$summary = this.$module.querySelector('.app-c-filter-section__summary')
    }

    init () {
      this.$summary.addEventListener('click', this.setTrackingData.bind(this))
    }

    setTrackingData () {
      const eventTrackingData = JSON.parse(this.$summary.getAttribute('data-ga4-event'))
      eventTrackingData.action = this.$module.hasAttribute('open') === false ? 'opened' : 'closed'
      this.$summary.setAttribute('data-ga4-event', JSON.stringify(eventTrackingData))
    }
  }

  Modules.FilterSection = FilterSection
})(window.GOVUK.Modules)
