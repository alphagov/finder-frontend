// TaxonomySelect adds interactivity to the topic taxonomy facet
(function ($) {
  'use strict'

  window.GOVUK = window.GOVUK || {}
  var GOVUK = window.GOVUK

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
    var topLevelTaxonSelected = !!this.$topLevelTaxon().value
    if (!topLevelTaxonSelected) {
      this.$subTaxon().setAttribute('disabled', true)
    } else {
      this.$subTaxon().removeAttribute('disabled')
    }
  }

  TaxonomySelect.prototype.showRelevantSubTaxons = function showRelevantSubTaxons () {
    var taxons = this.options[this.$topLevelTaxon().value]
    var subtaxon = this.$subTaxon()
    var options = subtaxon.querySelectorAll('option')

    for (var o = 0; o < options.length; o++) {
      if (options[o].value) {
        options[o].parentNode.removeChild(options[o])
      }
    }
    if (taxons) {
      for (var i = 0; i < taxons.length; i++) {
        subtaxon.appendChild(taxons[i])
      }
    }
  }

  TaxonomySelect.prototype.instantiateOptions = function instantiateOptions () {
    var options = {}
    var optionElements = this.$subTaxon().querySelectorAll('option')

    for (var o = 0; o < optionElements.length; o++) {
      var parent = optionElements[o].getAttribute('data-topic-parent')

      options[parent] = options[parent] || []
      options[parent].push(optionElements[o])
    }
    return options
  }

  TaxonomySelect.prototype.resetSubTaxonValue = function resetSubTaxonValue () {
    var selected = this.$subTaxon().options[this.$subTaxon().selectedIndex]
    var parentTaxon = this.$topLevelTaxon().value
    var isOrphanedSubTaxon = selected && selected.getAttribute('data-topic-parent') !== parentTaxon

    if (isOrphanedSubTaxon) {
      this.$subTaxon().value = ''
    }
  }

  GOVUK.TaxonomySelect = TaxonomySelect
})(jQuery)
