describe('TaxonomySelect', function () {
  var $facet, taxonomySelect

  beforeEach(function () {
    $facet = $("<div class='app-taxonomy-select'><div class='govuk-form-group gem-c-select'><label class='govuk-label' for='level_one_taxon'>Filter by topic</label><select class='govuk-select' id='level_one_taxon' name='level_one_taxon'><option value=''>All topics</option><option value='christmas'>Christmas</option><option value='halloween'>Halloween</option><option value='easter'>Easter</option></select></div><div class='js-required govuk-form-group gem-c-select'><label class='govuk-label' for='level_two_taxon'>Filter by sub-topic</label><select class='govuk-select' id='level_two_taxon' name='level_two_taxon' disabled='disabled'><option data-topic-parent='' value=''>All sub-topics</option><option data-topic-parent='christmas' value='presents'>Presents</option><option data-topic-parent='christmas' value='christmas-tree'>Christmas tree</option><option data-topic-parent='easter' value='easter-eggs'>Easter eggs</option><option data-topic-parent='halloween' value='trick-or-treat'>Trick or treat</option><option data-topic-parent='easter' value='easter-bunny'>Easter bunny</option></select></div></div>")

    $('body').append($facet)

    taxonomySelect = new GOVUK.TaxonomySelect({ $el: $facet[0] })
  })

  afterEach(function () {
    $facet.remove()
  })

  it('should have access the top level taxon', function () {
    expect(taxonomySelect.$topLevelTaxon().length).toBeTruthy()
  })

  it('should have access the second level taxon', function () {
    expect(taxonomySelect.$subTaxon().length).toBeTruthy()
  })

  it('will show relevant sub taxons', function () {
    function displayedSubTopicParents () {
      var parents = []

      var options = taxonomySelect.$subTaxon().querySelectorAll('option')
      for (var i = 0; i < options.length; i++) {
        var option = options[i]
        if (option.style.display !== 'none' && option.getAttribute('data-topic-parent')) {
          parents.push(
            option.getAttribute('data-topic-parent')
          )
        }
      }
      return parents
    }

    // User selects easter as the topic
    taxonomySelect.$topLevelTaxon().value = 'easter'
    taxonomySelect.showRelevantSubTaxons()
    expect(displayedSubTopicParents().length).toBe(2) // 2 displayed sub-topics
    expect(displayedSubTopicParents()[0]).toBe('easter')
    expect(displayedSubTopicParents()[1]).toBe('easter')

    // They then select christmas
    taxonomySelect.$topLevelTaxon().value = 'christmas'
    taxonomySelect.showRelevantSubTaxons()
    expect(displayedSubTopicParents().length).toBe(2) // 2 displayed sub-topics
    expect(displayedSubTopicParents()[0]).toBe('christmas')
    expect(displayedSubTopicParents()[1]).toBe('christmas')

    // Then halloween!
    taxonomySelect.$topLevelTaxon().value = 'halloween'
    taxonomySelect.showRelevantSubTaxons()
    expect(displayedSubTopicParents().length).toBe(1) // 1 displayed sub-topic
    expect(displayedSubTopicParents()[0]).toBe('halloween')
  })

  it('will reset the sub-taxon value on top-level-taxon change', function () {
    // user selects easter as the topic, then easter eggs as a sub topic
    taxonomySelect.$topLevelTaxon().value = 'easter'
    taxonomySelect.$subTaxon().value = 'easter-eggs'

    // user selects christmas as a topic
    taxonomySelect.$topLevelTaxon().value = 'christmas'
    taxonomySelect.resetSubTaxonValue()

    expect(taxonomySelect.$subTaxon().value).toBeFalsy()
  })

  it('will disable the sub taxon facet when a top-level taxon is not selected', function () {
    function isSubTaxonDisabled () {
      return !!taxonomySelect.$subTaxon().getAttribute('disabled')
    }

    // User has not yet selected a top-level topic
    expect(isSubTaxonDisabled()).toBe(true)

    // User selects a top-level topic
    taxonomySelect.$topLevelTaxon().value = 'christmas'
    taxonomySelect.disableSubTaxonFacet()
    expect(isSubTaxonDisabled()).toBe(false)

    // User selects default top-level topic again
    taxonomySelect.$topLevelTaxon().value = ''
    taxonomySelect.disableSubTaxonFacet()
    expect(isSubTaxonDisabled()).toBe(true)
  })
})
