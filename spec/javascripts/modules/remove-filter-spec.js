/* eslint-env jasmine, jquery */

var $ = window.jQuery

describe('remove-filter', function () {
  'use strict'

  var GOVUK = window.GOVUK
  var timeout = 500
  var removeFilter
  var $checkbox = $(
    '<div data-module="remove-filter">' +
    '<button href="/search/news-and-communications" class="remove-filter" role="button" aria-label="Remove filter transition period" data-module="remove-filter-link" data-facet="related_to_brexit" data-value="true" data-track-label="transition period" data-name="">✕</button>' +
  '</div>')

  var $oneTextQuery = $(
    '<div data-module="remove-filter">' +
      '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter education" data-module="remove-filter-link" data-facet="keywords" data-value="education" data-track-label="Education" data-name="keywords">✕</button>' +
    '</div>'
  )

  var $multipleTextQueries = $(
    '<div data-module="remove-filter">' +
      '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter the" data-module="remove-filter-link" data-facet="keywords" data-value="the" data-track-label="the" data-name="keywords">✕</button>' +
    '</div>'
  )

  var $quotedTextQuery = $(
    '<div data-module="remove-filter">' +
      '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fi&amp;quot;" data-module="remove-filter-link" data-track-label="&quot;fi&quot;" data-facet="keywords" data-value="&amp;quot;fi&amp;quot;" data-name="keywords">✕</button>' +
    '</div>'
  )

  var $quotedTextQuerySpaces = $(
    '<div data-module="remove-filter">' +
      '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fee fi fo&amp;quot;" data-module="remove-filter-link" data-track-label="&quot;fee fi fo&quot;" data-facet="keywords" data-value="&amp;quot;fee fi fo&amp;quot;" data-name="keywords">✕</button>' +
    '</div>'
  )

  var $dropdown = $(
    '<div data-module="remove-filter">' +
      '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter Entering and staying in the UK" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="ba3a9702-da22-487f-86c1-8334a730e559" data-track-label="Entering and staying in the UK" data-name="">✕</button>' +
    '</div>'
  )

  var $facetTagOne = $(
    '<div data-module="remove-filter">' +
      '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="aa3a9702-da22-487f-86c1-8334a730e558" data-track-label="A level one taxon" data-name="">✕</button>' +
      '</div>'
  )

  var $facetTagTwo = $(
    '<div data-module="remove-filter">' +
     '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter" data-module="remove-filter-link" data-facet="level_two_taxon" data-value="bb3a9702-da22-487f-86c1-8334a730e559" data-track-label="Sub taxon" data-name="">✕</button>' +
   '</div>'
  )

  var $facets =
    '<select id="level_one_taxon" name="level_one_taxon">' +
      '<option value="">All topics</option>' +
      '<option value="ba3a9702-da22-487f-86c1-8334a730e559">Entering and staying in the UK</option>' +
    '</select>' +
    '<div id="keywords">' +
      '<input name="keywords" value="" id="finder-keyword-search" type="text">' +
    '</div>' +
    '<div>' +
      '<input name="public_timestamp[from]" value="" id="public_timestamp[from]" type="text">' +
    '</div>' +
    '<div id="related_to_brexit">' +
      '<input type="checkbox" name="related_to_brexit" value="true" data-module="track-click">' +
    '</div>'

  beforeEach(function () {
    $(document.body).append($facets)
    removeFilter = new GOVUK.Modules.RemoveFilter()
    spyOn(GOVUK.SearchAnalytics, 'trackEvent')
  })

  afterEach(function () {
    GOVUK.SearchAnalytics.trackEvent.calls.reset()
  })

  it('deselects a selected checkbox', function (done) {
    var checkbox = $('input[name=related_to_brexit]')[0]
    checkbox.checked = true
    removeFilter.start($checkbox)

    expect(checkbox.checked).toBe(true)

    triggerRemoveFilterClick($checkbox)

    setTimeout(function () {
      expect(checkbox.checked).toBe(false)
      done()
    }, timeout)
  })

  it('clears the text search field if removing all text queries', function (done) {
    var searchField = $('input[name=keywords]')[0]
    searchField.value = 'education'
    removeFilter.start($oneTextQuery)

    expect(searchField.value).toContain('education')

    triggerRemoveFilterClick($oneTextQuery)

    setTimeout(function () {
      expect(searchField.value).toEqual('')
      done()
    }, timeout)
  })

  it('removes one text query from the text search field if there are multiple', function (done) {
    var searchField = $('input[name=keywords]')[0]
    searchField.value = 'therefore the search term'
    removeFilter.start($multipleTextQueries)

    expect(searchField.value).toContain('the')

    triggerRemoveFilterClick($multipleTextQueries)

    setTimeout(function () {
      expect(searchField.value).toEqual('therefore search term')
      done()
    }, timeout)
  })

  it('removes text queries with quotes from the text search field', function (done) {
    var searchField = $('input[name=keywords]')[0]
    searchField.value = 'fee "fi" fo fum'
    removeFilter.start($quotedTextQuery)

    expect(searchField.value).toContain('"fi"')

    triggerRemoveFilterClick($quotedTextQuery)

    setTimeout(function () {
      expect(searchField.value).toEqual('fee fo fum')
      done()
    }, timeout)
  })

  it('removes text queries with multiple words inside quotes from the text search field', function (done) {
    var searchField = $('input[name=keywords]')[0]
    searchField.value = '"fee fi fo" fum'
    removeFilter.start($quotedTextQuerySpaces)

    expect(searchField.value).toContain('"fee fi fo"')

    triggerRemoveFilterClick($quotedTextQuerySpaces)

    setTimeout(function () {
      expect(searchField.value).toEqual('fum')
      done()
    }, timeout)
  })

  it('sets default state for dropdown', function (done) {
    var dropdown = $('select[name=level_one_taxon]')[0]
    dropdown.value = 'ba3a9702-da22-487f-86c1-8334a730e559'
    var selectedValue = dropdown.options[dropdown.selectedIndex].value

    removeFilter.start($dropdown)

    expect(selectedValue).toEqual('ba3a9702-da22-487f-86c1-8334a730e559')

    triggerRemoveFilterClick($dropdown)

    setTimeout(function () {
      expect(dropdown.options[dropdown.selectedIndex].value).toEqual('')
      done()
    }, timeout)
  })

  describe('Clicking the "x" button in facet tags', function () {
    it('triggers a google analytics custom event', function () {
      removeFilter.start($facetTagOne)

      triggerRemoveFilterClick($facetTagOne)

      expect(GOVUK.SearchAnalytics.trackEvent).toHaveBeenCalledWith('facetTagRemoved', 'level_one_taxon', {
        label: 'A level one taxon'
      })
    })

    it('triggers a google analytics custom event when second facet tag removed', function () {
      removeFilter.start($facetTagOne)
      removeFilter.start($facetTagTwo)

      triggerRemoveFilterClick($facetTagOne)
      triggerRemoveFilterClick($facetTagTwo)

      expect(GOVUK.SearchAnalytics.trackEvent).toHaveBeenCalledWith('facetTagRemoved', 'level_two_taxon', {
        label: 'Sub taxon'
      })
    })
  })
})

function triggerRemoveFilterClick (element) {
  element.find('button[data-module=remove-filter-link]').trigger('click')
}
