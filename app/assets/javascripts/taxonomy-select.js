//
// TaxonomySelect adds interactivity to the topic taxonomy facet.
//

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
    return this.$el.find('#level_one_taxon')
  }

  TaxonomySelect.prototype.$subTaxon = function $subTaxon () {
    return this.$el.find('#level_two_taxon')
  }

  TaxonomySelect.prototype.disableSubTaxonFacet = function disableSubTaxonFacet () {
    var topLevelTaxonSelected = !!this.$topLevelTaxon().val()
    this.$subTaxon().attr('disabled', !topLevelTaxonSelected)
  }

  TaxonomySelect.prototype.showRelevantSubTaxons = function showRelevantSubTaxons () {
    var taxons = this.options[this.$topLevelTaxon().val()]

    var subtaxon = this.$subTaxon()

    subtaxon.find('option').each(function () {
      if ($(this).val()) { $(this).remove() }
    })

    subtaxon.append(taxons)
  }

  TaxonomySelect.prototype.instantiateOptions = function instantiateOptions () {
    var options = {}

    this.$subTaxon().find('option').each(function () {
      var parent = $(this).attr('data-topic-parent')

      options[parent] = options[parent] || []
      options[parent].push(this)
    })

    return options
  }

  TaxonomySelect.prototype.resetSubTaxonValue = function resetSubTaxonValue () {
    var selected = this.$subTaxon().find(':selected')

    var parentTaxon = this.$topLevelTaxon().val()

    var isOrphanedSubTaxon = selected && selected.attr('data-topic-parent') !== parentTaxon

    if (isOrphanedSubTaxon) {
      this.$subTaxon().val('')
    }
  }

  GOVUK.TaxonomySelect = TaxonomySelect
})(jQuery)
