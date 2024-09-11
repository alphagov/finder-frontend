window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  class FilterPanel {
    constructor ($module) {
      this.$module = $module
      this.$button = this.$module.querySelector('.app-c-filter-panel__button')
      this.$panel = this.$module.querySelector(`#${this.$button.getAttribute('aria-controls')}`)
      this.$button.setAttribute('aria-expanded', 'false')
      this.$panel.setAttribute('hidden', '')
      this.isOpen = false
    }

    init () {
      this.$button.addEventListener('click', this.onButtonClick.bind(this))
      this.$button.addEventListener('blur', this.onButtonBlur.bind(this))
    }

    onButtonBlur () {
      this.$button.classList.remove('app-c-filter-panel__button--focused')
    }

    onButtonClick (event) {
      event.preventDefault()
      this.$button.classList.add('app-c-filter-panel__button--focused')
      this.toggle()
    }

    toggle () {
      this.isOpen = !this.isOpen
      this.$button.setAttribute('aria-expanded', `${this.isOpen}`)

      if (this.isOpen) {
        this.$panel.removeAttribute('hidden')
      } else {
        this.$panel.setAttribute('hidden', '')
      }
    }
  }

  Modules.FilterPanel = FilterPanel
})(window.GOVUK.Modules)
