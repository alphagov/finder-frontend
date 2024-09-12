window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  class FilterPanel {
    constructor ($module) {
      this.$module = $module
      this.$button = this.$module.querySelector('.app-c-filter-panel__button')
      this.$content = this.$module.querySelector('.app-c-filter-panel__content')
    }

    init () {
      if (this.$module.getAttribute('open')) {
        this.$button.setAttribute('aria-expanded', 'true')
      } else {
        this.$button.setAttribute('aria-expanded', 'false')
        this.$content.setAttribute('hidden', '')
      }

      this.$button.addEventListener('click', this.onButtonClick.bind(this))
    }

    onButtonClick (event) {
      event.preventDefault()
      this.toggle()
    }

    toggle () {
      const newState = this.$button.getAttribute('aria-expanded') !== 'true'
      this.$button.setAttribute('aria-expanded', newState)
      this.$content.toggleAttribute('hidden')
    }
  }

  Modules.FilterPanel = FilterPanel
})(window.GOVUK.Modules)
