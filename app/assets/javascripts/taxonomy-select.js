window.GOVUK = window.GOVUK || {};

(function (GOVUK) {
  'use strict'

  function TaxonomySelect (options) {
    this.$el = options.$el
    this.options = this.instantiateOptions()
  }

  TaxonomySelect.prototype.update = function updateTaxonomyFacet () {
    this.disableSubTaxonFacet()
    this.resetSubTaxonValue()
    this.showRelevantSubTaxons()
  }

  TaxonomySelect.prototype.$topLevelTaxon = function $topLevelTaxon () {
    return this.$el.querySelector('#level_one_taxon')
  }

  TaxonomySelect.prototype.$subTaxon = function $subTaxon () {
    return this.$el.querySelector('#level_two_taxon')
  }

  TaxonomySelect.prototype.disableSubTaxonFacet = function disableSubTaxonFacet () {
    const topLevelTaxonSelected = !!this.$topLevelTaxon().value
    if (!topLevelTaxonSelected) {
      this.$subTaxon().setAttribute('disabled', true)
    } else {
      this.$subTaxon().removeAttribute('disabled')
    }
  }

  TaxonomySelect.prototype.showRelevantSubTaxons = function showRelevantSubTaxons () {
    const taxons = this.options[this.$topLevelTaxon().value]
    const subtaxon = this.$subTaxon()
    const options = subtaxon.querySelectorAll('option')

    for (let o = 0; o < options.length; o++) {
      if (options[o].value) {
        options[o].parentNode.removeChild(options[o])
      }
    }
    if (taxons) {
      for (let i = 0; i < taxons.length; i++) {
        subtaxon.appendChild(taxons[i])
      }
    }
  }

  TaxonomySelect.prototype.instantiateOptions = function instantiateOptions () {
    const options = {}
    const optionElements = this.$subTaxon().querySelectorAll('option')

    for (let o = 0; o < optionElements.length; o++) {
      const parent = optionElements[o].getAttribute('data-topic-parent')

      options[parent] = options[parent] || []
      options[parent].push(optionElements[o])
    }
    return options
  }

  TaxonomySelect.prototype.resetSubTaxonValue = function resetSubTaxonValue () {
    const selected = this.$subTaxon().options[this.$subTaxon().selectedIndex]
    const parentTaxon = this.$topLevelTaxon().value
    const isOrphanedSubTaxon = selected && selected.getAttribute('data-topic-parent') !== parentTaxon

    if (isOrphanedSubTaxon) {
      this.$subTaxon().value = ''
    }
  }

  GOVUK.TaxonomySelect = TaxonomySelect
})(window.GOVUK)
