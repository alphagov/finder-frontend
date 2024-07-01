describe('remove-filter', function () {
  'use strict'

  var GOVUK = window.GOVUK
  var timeout = 500
  var facets

  function createRemoveFilter (innerHTML) {
    var filter = document.createElement('div')
    filter.classList.add('remove-filter')
    filter.innerHTML = innerHTML
    return filter
  }

  function triggerRemoveFilterClick (element) {
    var button = element.querySelector('button[data-module=remove-filter-link]')
    window.GOVUK.triggerEvent(button, 'click')
  }

  var checkboxFilter = createRemoveFilter(
    '<button href="/search/news-and-communications" class="remove-filter" role="button" aria-label="Remove filter transition period" data-module="remove-filter-link" data-facet="a_check_box" data-value="true" data-name="">✕</button>'
  )

  var oneTextQueryFilter = createRemoveFilter(
    '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter education" data-module="remove-filter-link" data-facet="keywords" data-value="education" data-name="keywords">✕</button>'
  )

  var multipleTextQueriesFilter = createRemoveFilter(
    '<button href="/search/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter the" data-module="remove-filter-link" data-facet="keywords" data-value="the" data-name="keywords">✕</button>'
  )

  var quotedTextQueryFilter = createRemoveFilter(
    '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fi&amp;quot;" data-module="remove-filter-link" data-facet="keywords" data-value="&amp;quot;fi&amp;quot;" data-name="keywords">✕</button>'
  )

  var quotedTextQuerySpacesFilter = createRemoveFilter(
    '<button type="button" class="facet-tag__remove" aria-label="Remove filter &amp;quot;fee fi fo&amp;quot;" data-module="remove-filter-link" data-facet="keywords" data-value="&amp;quot;fee fi fo&amp;quot;" data-name="keywords">✕</button>'
  )

  var dropdownFilter = createRemoveFilter(
    '<button href="/search/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter Entering and staying in the UK" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="ba3a9702-da22-487f-86c1-8334a730e559" data-name="">✕</button>'
  )

  var facetsHTML =
    '<select id="level_one_taxon" name="level_one_taxon" class="js-remove">' +
      '<option value="">All topics</option>' +
      '<option value="ba3a9702-da22-487f-86c1-8334a730e559">Entering and staying in the UK</option>' +
    '</select>' +
    '<select id="level_two_taxon" name="level_two_taxon" class="js-remove">' +
      '<option value="">All topics</option>' +
      '<option value="bb3a9702-da22-487f-86c1-8334a730e559">Entering and staying in the UK</option>' +
    '</select>' +
    '<div id="keywords" class="js-remove">' +
      '<input name="keywords" value="" id="finder-keyword-search" type="text">' +
    '</div>' +
    '<div class="js-remove">' +
      '<input name="public_timestamp[from]" value="" id="public_timestamp[from]" type="text">' +
    '</div>' +
    '<div id="a_check_box" class="js-remove">' +
      '<input type="checkbox" name="a_check_box" value="true">' +
    '</div>'

  beforeEach(function () {
    facets = document.createElement('div')
    facets.innerHTML = facetsHTML
    document.body.appendChild(facets)
  })

  afterEach(function () {
    document.body.removeChild(facets)
  })

  it('deselects a selected checkbox', function (done) {
    var checkbox = facets.querySelector('input[name=a_check_box]')
    checkbox.checked = true
    new GOVUK.Modules.RemoveFilter(checkboxFilter).init()

    expect(checkbox.checked).toBe(true)

    triggerRemoveFilterClick(checkboxFilter)

    setTimeout(function () {
      expect(checkbox.checked).toBe(false)
      done()
    }, timeout)
  })

  it('clears the text search field if removing all text queries', function (done) {
    var searchField = facets.querySelector('input[name=keywords]')
    searchField.value = 'education'
    new GOVUK.Modules.RemoveFilter(oneTextQueryFilter).init()

    expect(searchField.value).toContain('education')

    triggerRemoveFilterClick(oneTextQueryFilter)

    setTimeout(function () {
      expect(searchField.value).toEqual('')
      done()
    }, timeout)
  })

  it('removes one text query from the text search field if there are multiple', function (done) {
    var searchField = facets.querySelector('input[name=keywords]')
    searchField.value = 'therefore the search term'
    new GOVUK.Modules.RemoveFilter(multipleTextQueriesFilter).init()

    expect(searchField.value).toContain('the')

    triggerRemoveFilterClick(multipleTextQueriesFilter)

    setTimeout(function () {
      expect(searchField.value).toEqual('therefore search term')
      done()
    }, timeout)
  })

  it('removes text queries with quotes from the text search field', function (done) {
    var searchField = facets.querySelector('input[name=keywords]')
    searchField.value = 'fee "fi" fo fum'
    new GOVUK.Modules.RemoveFilter(quotedTextQueryFilter).init()

    expect(searchField.value).toContain('"fi"')

    triggerRemoveFilterClick(quotedTextQueryFilter)

    setTimeout(function () {
      expect(searchField.value).toEqual('fee fo fum')
      done()
    }, timeout)
  })

  it('removes text queries with multiple words inside quotes from the text search field', function (done) {
    var searchField = facets.querySelector('input[name=keywords]')
    searchField.value = '"fee fi fo" fum'
    new GOVUK.Modules.RemoveFilter(quotedTextQuerySpacesFilter).init()

    expect(searchField.value).toContain('"fee fi fo"')

    triggerRemoveFilterClick(quotedTextQuerySpacesFilter)

    setTimeout(function () {
      expect(searchField.value).toEqual('fum')
      done()
    }, timeout)
  })

  it('sets default state for dropdown', function (done) {
    var dropdown = facets.querySelector('select[name=level_one_taxon]')
    dropdown.value = 'ba3a9702-da22-487f-86c1-8334a730e559'
    var selectedValue = dropdown.options[dropdown.selectedIndex].value

    new GOVUK.Modules.RemoveFilter(dropdownFilter).init()

    expect(selectedValue).toEqual('ba3a9702-da22-487f-86c1-8334a730e559')

    triggerRemoveFilterClick(dropdownFilter)

    setTimeout(function () {
      expect(dropdown.options[dropdown.selectedIndex].value).toEqual('')
      done()
    }, timeout)
  })
})
