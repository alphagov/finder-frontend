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

      // TODO: This does not belong here in the long run, but makes it work for now
      const taxonomySelect = this.$module.querySelector('.js-taxonomy-select')
      if (taxonomySelect) {
        this.taxonomy = this.taxonomy || new GOVUK.TaxonomySelect({ $el: taxonomySelect })
        this.taxonomy.update()

        taxonomySelect.querySelector('#level_one_taxon').addEventListener('change', (_event) => {
          this.taxonomy.update()
        })
      }
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
