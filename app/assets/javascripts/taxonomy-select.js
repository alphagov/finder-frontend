//
// TaxonomySelect adds interactivity to the topic taxonomy facet.
//

(function ($) {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function TaxonomySelect(options) {
    this.$el = options.$el;
  }

  TaxonomySelect.prototype.update = function updateTaxonomyFacet(){
    this.disableSubTaxonFacet();
    this.showRelevantSubTaxons();
    this.resetSubTaxonValue();
  };

  TaxonomySelect.prototype.$topLevelTaxon = function $topLevelTaxon() {
    return this.$el.find('#level_one_taxon');
  };

  TaxonomySelect.prototype.$subTaxon = function $subTaxon() {
    return this.$el.find('#level_two_taxon');
  };

  TaxonomySelect.prototype.disableSubTaxonFacet = function disableSubTaxonFacet() {
    var topLevelTaxonSelected = !!this.$topLevelTaxon().val();
    this.$subTaxon().attr('disabled', !topLevelTaxonSelected);
  };

  TaxonomySelect.prototype.showRelevantSubTaxons = function showRelevantSubTaxons() {
    var parentTaxon = this.$topLevelTaxon().val();

    this.$subTaxon().find('option').each(function(){
      var taxon = $(this),
          isChildOfSelected = $(taxon).attr('data-topic-parent') === parentTaxon,
          isDefaultOption = !$(taxon).val(),
          shouldDisplay = isChildOfSelected || isDefaultOption;

      $(taxon).toggle(shouldDisplay);
    });
  };

  TaxonomySelect.prototype.resetSubTaxonValue = function resetSubTaxonValue() {
    var selected = this.$subTaxon().find(':selected'),
        parentTaxon = this.$topLevelTaxon().val(),
        isOrphanedSubTaxon = selected && selected.attr('data-topic-parent') !== parentTaxon;

    if (isOrphanedSubTaxon) {
      this.$subTaxon().val('');
    }
  };

  GOVUK.TaxonomySelect = TaxonomySelect;

})(jQuery);
