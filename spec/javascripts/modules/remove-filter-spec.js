describe('remove-filter', function () {
  'use strict'

  var GOVUK = window.GOVUK
  var timeout = 500
  var removeFilter

  var $checkbox = document.createElement('div')
  $checkbox.setAttribute('data-module', 'remove-filter')
  $checkbox.innerHTML = '<button href="/search/news-and-communications" class="remove-filter" role="button" aria-label="Remove filter transition period" data-module="remove-filter-link" data-facet="a_check_box" data-value="true" data-track-label="transition period" data-name="">✕</button>'

  var $oneTextQuery = document.createElement('div')
  $oneTextQuery.setAttribute('data-module', 'remove-filter')
  $oneTextQuery.innerHTML = '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter education" data-module="remove-filter-link" data-facet="keywords" data-value="education" data-track-label="Education" data-name="keywords">✕</button>'

  var $multipleTextQueries = document.createElement('div')
  $multipleTextQueries.setAttribute('data-module', 'remove-filter')
  $multipleTextQueries.innerHTML = '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter the" data-module="remove-filter-link" data-facet="keywords" data-value="the" data-track-label="the" data-name="keywords">✕</button>'

  var $quotedTextQuery = document.createElement('div')
  $quotedTextQuery.setAttribute('data-module', 'remove-filter')
  $quotedTextQuery.innerHTML = '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fi&amp;quot;" data-module="remove-filter-link" data-track-label="&quot;fi&quot;" data-facet="keywords" data-value="&amp;quot;fi&amp;quot;" data-name="keywords">✕</button>'

  var $quotedTextQuerySpaces = document.createElement('div')
  $quotedTextQuerySpaces.setAttribute('data-module', 'remove-filter')
  $quotedTextQuerySpaces.innerHTML = '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fee fi fo&amp;quot;" data-module="remove-filter-link" data-track-label="&quot;fee fi fo&quot;" data-facet="keywords" data-value="&amp;quot;fee fi fo&amp;quot;" data-name="keywords">✕</button>'

  var $dropdown = document.createElement('div')
  $dropdown.setAttribute('data-module', 'remove-filter')
  $dropdown.innerHTML = '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter Entering and staying in the UK" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="ba3a9702-da22-487f-86c1-8334a730e559" data-track-label="Entering and staying in the UK" data-name="">✕</button>'

  var $facetTagOne = document.createElement('div')
  $facetTagOne.setAttribute('data-module', 'remove-filter')
  $facetTagOne.innerHTML = '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="aa3a9702-da22-487f-86c1-8334a730e558" data-track-label="A level one taxon" data-name="">✕</button>'

  var $facetTagTwo = document.createElement('div')
  $facetTagTwo.setAttribute('data-module', 'remove-filter')
  $facetTagTwo.innerHTML = '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter" data-module="remove-filter-link" data-facet="level_two_taxon" data-value="bb3a9702-da22-487f-86c1-8334a730e559" data-track-label="Sub taxon" data-name="">✕</button>'

  var $facetSelect = document.createElement('select')
  $facetSelect.setAttribute('id', 'level_one_taxon')
  $facetSelect.setAttribute('name', 'level_one_taxon')

  var $facetDivOne = document.createElement('div')
  $facetDivOne.setAttribute('id', 'keywords')
  $facetDivOne.innerHTML = '<input name="keywords" value="" id="finder-keyword-search" type="text">'

  var $facetDivTwo = document.createElement('div')
  $facetDivTwo.innerHTML = '<input name="public_timestamp[from]" value="" id="public_timestamp[from]" type="text">'

  var $facetDivThree = document.createElement('div')
  $facetDivThree.setAttribute('id', 'a_check_box')
  $facetDivThree.innerHTML = '<input type="checkbox" name="a_check_box" value="true" data-module="gem-track-click">'

  beforeEach(function () {
    document.body.appendChild($facetSelect)
    document.body.appendChild($facetDivOne)
    document.body.appendChild($facetDivTwo)
    document.body.appendChild($facetDivThree)
    removeFilter = new GOVUK.Modules.RemoveFilter()
    spyOn(GOVUK.SearchAnalytics, 'trackEvent')
  })

  afterEach(function () {
    GOVUK.SearchAnalytics.trackEvent.calls.reset()
  })

  it('deselects a selected checkbox', function (done) {
    var checkbox = document.createElement('input')
    checkbox.setAttribute('name', 'a_check_box')
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
    var searchField = document.createElement('input')
    searchField.setAttribute('name', 'keywords')

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
    var searchField = document.createElement('input')
    searchField.setAttribute('name', 'keywords')
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
    var searchField = document.createElement('input')
    searchField.setAttribute('name', 'keywords')
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
    var searchField = document.createElement('input')
    searchField.setAttribute('name', 'keywords')
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
    var dropdown = document.createElement('select')
    dropdown.setAttribute('name', 'level_one_taxon')
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
   window.GOVUK.triggerEvent(element.querySelector('button[data-module=remove-filter-link]'), 'click')
}
