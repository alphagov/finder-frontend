var $ = window.jQuery

describe('remove-filter', function () {
  'use strict'

  var GOVUK = window.GOVUK
  var timeout = 500;
  var removeFilter;

  var $checkbox = $(
  '<div data-module="remove-filter">' +
    '<a href="/news-and-communications" class="remove-filter" role="button" aria-label="Remove filter Brexit" data-module="remove-filter-link" data-facet="related_to_brexit" data-value="true" data-name="">✕</a>' +
  '</div>');

  var $oneTextQuery = $(
    '<div data-module="remove-filter">' +
      '<a href="/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter education" data-module="remove-filter-link" data-facet="keywords" data-value="education" data-name="keywords">✕</a>' +
    '</div>'
  );

  var $multipleTextQueries = $(
    '<div data-module="remove-filter">' +
      '<a href="/news-and-communications?[]=education" class="remove-filter" role="button" aria-label="Remove filter education" data-module="remove-filter-link" data-facet="keywords" data-value="education" data-name="keywords">✕</a>' +
    '</div>'
  );

  var $dropdown = $(
    '<div data-module="remove-filter">' +
      '<a href="/news-and-communications?[][]=level_one_taxon&amp;[][]=ba3a9702-da22-487f-86c1-8334a730e559&amp;[][]=level_two_taxon&amp;[][]" class="remove-filter" role="button" aria-label="Remove filter Entering and staying in the UK" data-module="remove-filter-link" data-facet="level_one_taxon" data-value="ba3a9702-da22-487f-86c1-8334a730e559" data-name="">✕</a>' +
    '</div>'
  );

  var $facets =
    '<select id="level_one_taxon" name="level_one_taxon">' +
      '<option value="">All topics</option>' +
      '<option value="ba3a9702-da22-487f-86c1-8334a730e559">Entering and staying in the UK</option>' +
    '</select>' +
    '<div id="keywords">'+
      '<input name="keywords" value="" id="finder-keyword-search" type="text">' +
    '</div>' +
    '<div id="related_to_brexit">' +
      '<input type="checkbox" name="related_to_brexit" value="true" data-module="track-click">' +
    '</div>';

  beforeEach(function () {
    $(document.body).append($facets);
    removeFilter = new GOVUK.Modules.RemoveFilter();
  })

  it('deselects a selected checkbox', function (done) {
    var checkbox = $('input[name=related_to_brexit]')[0];
    checkbox.checked = true;
    removeFilter.start($checkbox);

    expect(checkbox.checked).toBe(true);

    triggerRemoveFilterClick($checkbox);

    setTimeout(function() {
      expect(checkbox.checked).toBe(false);
      done();
    }, timeout);
  })

  it('clears the text search field if removing all text queries', function (done) {
    var searchField = $('input[name=keywords]')[0];
    searchField.value = "education";
    removeFilter.start($oneTextQuery);

    expect(searchField.value).toContain("education");

    triggerRemoveFilterClick($oneTextQuery);

    setTimeout(function() {
      expect(searchField.value).toEqual("");
      done();
    }, timeout);
  })


  it('removes one text query from the text search field if there are multiple', function (done) {
    var searchField = $('input[name=keywords]')[0];
    searchField.value = "education another search term";
    removeFilter.start($multipleTextQueries);

    expect(searchField.value).toContain("education");

    triggerRemoveFilterClick($multipleTextQueries);

    setTimeout(function() {
      expect(searchField.value).toEqual("another search term");
      done();
    }, timeout);
  })


  it('sets default state for dropdown', function (done) {
    var dropdown = $('select[name=level_one_taxon]')[0];
    dropdown.value = 'ba3a9702-da22-487f-86c1-8334a730e559';
    var selectedValue = dropdown.options[dropdown.selectedIndex].value;

    removeFilter.start($dropdown);

    expect(selectedValue).toEqual('ba3a9702-da22-487f-86c1-8334a730e559');

    triggerRemoveFilterClick($dropdown);

    setTimeout(function() {
      expect(dropdown.options[dropdown.selectedIndex].value).toEqual("");
      done();
    }, timeout);
  })
});

function triggerRemoveFilterClick(element) {
  element.find('a[data-module=remove-filter-link]').trigger('click');
}
