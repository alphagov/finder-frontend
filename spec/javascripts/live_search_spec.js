/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('liveSearch', function () {
  var $form, $results, _supportHistory, liveSearch, $atomAutodiscoveryLink, $count
  var dummyResponse = {
    'display_total': 1,
    'pluralised_document_noun': 'reports',
    'applied_filters': " \u003Cstrong\u003ECommercial - rotorcraft \u003Ca href='?format=json\u0026keywords='\u003E×\u003C/a\u003E\u003C/strong\u003E",
    'atom_url': 'http://an-atom-url.atom?some-query-param',
    'documents': [
      {
        'document': {
          'title': 'Test report',
          'slug': 'aaib-reports/test-report',
          'metadata': [
            {
              'label': 'Aircraft category',
              'value': 'General aviation - rotorcraft',
              'is_text': true
            }, {
              'label': 'Report type',
              'value': 'Annual safety report',
              'is_text': true
            }, {
              'label': 'Occurred',
              'is_date': true,
              'machine_date': '2013-11-03',
              'human_date': '3 November 2013'
            }
          ]
        },
        'document_index': 1
      }
    ],
    'search_results': '<div class="finder-results js-finder-results" data-module="track-click">' +
      '<ol class="gem-c-document-list">' +
        '<li class="gem-c-document-list__item">' +
          '<a data-track-category="navFinderLinkClicked" data-track-action="" data-track-label="" class="gem-c-document-list__item-title" href="aaib-reports/test-report">Test report</a>' +
            '<p class="gem-c-document-list__item-description">The English business survey will provide Ministers and officials with information about the current economic and business conditions across</p>' +
            '<ul class="gem-c-document-list__item-metadata">' +
                '<li class="gem-c-document-list__attribute">' +
                    'Document type: Official Statistics' +
                '</li>' +
                '<li class="gem-c-document-list__attribute">' +
                    'Part of a collection: English business survey' +
                '</li>' +
                '<li class="gem-c-document-list__attribute">' +
                    'Organisation: Closed organisation: Department for Business, Innovation &amp; Skills' +
                '</li>' +
                '<li class="gem-c-document-list__attribute">' +
                    'Updated: <time datetime="2012-12-21">21 December 2012</time>' +
                '</li>' +
            '</ul>' +
        '</li>' +
      '</ol>' +
    '</div>'
  }

  var responseWithSortOptions = {
    'sort_options_markup': '<select id="order">' +
      '<option ' +
        'value="option-val" ' +
        'data_track_category="option-data_track_category"' +
        'data_track_action="option-data_track_action"' +
        'data_track_label="option-data_track_label"' +
        'selected' +
        '/>' +
      '<option ' +
        'value="option-val-2" ' +
        'data_track_category="option-data_track_category-2"' +
        'data_track_action="option-data_track_action-2"' +
        'data_track_label="option-data_track_label-2"' +
        'disabled' +
        '/>' +
    '</select>'
  }

  beforeEach(function () {
    var sortList = '<select id="order" class="js-order-results" data-relevance-sort-option="relevance"><option>Test 1</option><option value="relevance" disabled>Relevance</option>'
    $form = $('<form action="/somewhere" class="js-live-search-form">' +
                '<input type="checkbox" name="field" value="sheep" checked>' +
                '<label for="published_at">Published at</label>' +
                '<input type="text" name="published_at" value="2004" />' +
                '<input type="text" name="option-select-filter" value="notincluded"/>' +
                '<input type="text" name="unused_facet"/>' +
                '<input type="submit" value="Filter results" class="button js-live-search-fallback"/>' +
              '</form>')
    $results = $('<div class="js-live-search-results-block"><div id="js-sort-options">' + sortList + '</div></div>')
    $count = $('<div aria-live="assertive" id="js-search-results-info"><h2 class="result-region-header__counter" id="f-result-count"></h2></div>')
    $atomAutodiscoveryLink = $("<link href='http://an-atom-url.atom' rel='alternate' title='ATOM' type='application/atom+xml'>")
    var $emailSubscriptionLinks = $("<a href='https://a-url/email-signup?query_param=something'>")
    var $feedSubscriptionLinks = $("<a href='http://an-atom-url.atom?query_param=something'>")
    $('body').append($form).append($results).append($atomAutodiscoveryLink).append($feedSubscriptionLinks).append($emailSubscriptionLinks)
    $('head').append('<meta name="govuk:base_title" content="All Content - GOV.UK">')
    _supportHistory = GOVUK.support.history
    GOVUK.support.history = function () { return true }
    window.ga = function () {}
    spyOn(window, 'ga')
    liveSearch = new GOVUK.LiveSearch({ $form: $form, $results: $results, $atomAutodiscoveryLink: $atomAutodiscoveryLink })
  })

  afterEach(function () {
    $form.remove()
    $results.remove()
    GOVUK.support.history = _supportHistory
  })

  it('sets the GA transport to beacon', function () {
    expect(window.ga).toHaveBeenCalledWith('set', 'transport', 'beacon')
  })

  it('should save initial state (serialized and compacted)', function () {
    expect(liveSearch.state).toEqual([{ name: 'field', value: 'sheep' }, { name: 'published_at', value: '2004' }])
  })

  it('should detect a new state', function () {
    expect(liveSearch.isNewState()).toBe(false)
    $form.find('input[name="field"]').prop('checked', false)
    expect(liveSearch.isNewState()).toBe(true)
  })

  it('should update state to current state', function () {
    expect(liveSearch.state).toEqual([{ name: 'field', value: 'sheep' }, { name: 'published_at', value: '2004' }])
    $form.find('input[name="field"]').prop('checked', false)
    liveSearch.saveState()
    expect(liveSearch.state).toEqual([{ name: 'published_at', value: '2004' }])
  })

  it('should update state to passed in state', function () {
    expect(liveSearch.state).toEqual([{ name: 'field', value: 'sheep' }, { name: 'published_at', value: '2004' }])
    $form.find('input[name="field"]').prop('checked', false)
    liveSearch.saveState({ my: 'new', state: 'object' })
    expect(liveSearch.state).toEqual({ my: 'new', state: 'object' })
  })

  it('should not request new results if they are in the cache', function () {
    liveSearch.resultCache['more=results'] = 'exists'
    liveSearch.state = { more: 'results' }
    spyOn(liveSearch, 'displayResults')
    spyOn(jQuery, 'ajax')

    liveSearch.updateResults()
    expect(liveSearch.displayResults).toHaveBeenCalled()
    expect(jQuery.ajax).not.toHaveBeenCalled()
  })

  it('should return a promise like object if results are in the cache', function () {
    liveSearch.resultCache['more=results'] = 'exists'
    liveSearch.state = { more: 'results' }
    spyOn(liveSearch, 'displayResults')
    spyOn(jQuery, 'ajax')

    var promise = liveSearch.updateResults()
    expect(typeof promise.done).toBe('function')
  })

  it("should return a promise like object if results aren't in the cache", function () {
    liveSearch.state = { not: 'cached' }
    spyOn(liveSearch, 'displayResults')
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error'])
    ajaxCallback.done.and.returnValue(ajaxCallback)
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback)

    liveSearch.updateResults()
    expect(jQuery.ajax).toHaveBeenCalledWith({ url: '/somewhere.json', data: { not: 'cached' }, searchState: 'not=cached' })
    expect(ajaxCallback.done).toHaveBeenCalled()
    ajaxCallback.done.calls.mostRecent().args[0]('response data')
    expect(liveSearch.displayResults).toHaveBeenCalled()
    expect(liveSearch.resultCache['not=cached']).toBe('response data')
  })

  it('should show error indicator when error loading new results', function () {
    liveSearch.state = { not: 'cached' }
    spyOn(liveSearch, 'displayResults')
    spyOn(liveSearch, 'showErrorIndicator')
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error'])
    ajaxCallback.done.and.returnValue(ajaxCallback)
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback)

    liveSearch.updateResults()
    ajaxCallback.error.calls.mostRecent().args[0]()
    expect(liveSearch.showErrorIndicator).toHaveBeenCalled()
  })

  it('should return cache items for current state', function () {
    liveSearch.state = { not: 'cached' }
    expect(liveSearch.cache('some-slug')).toBe(undefined)
    liveSearch.cache('some-slug', 'something in the cache')
    expect(liveSearch.cache('some-slug')).toBe('something in the cache')
  })

  describe('should not display out of date results', function () {
    it('should not update the results if the state associated with these results is not the current state of the page', function () {
      liveSearch.state = 'cma-cases.json?keywords=123'
      spyOn(liveSearch, 'updateElement')
      liveSearch.displayResults(dummyResponse, 'made up state')
      expect(liveSearch.updateElement).not.toHaveBeenCalled()
    })

    it('should have an order state selected when keywords are present', function () {
      liveSearch.state = 'find-eu-exit-guidance-business.json?keywords=123'
      expect(liveSearch.$orderSelect.val()).not.toBe(null)
    })

    it('should update the results if the state of these results matches the state of the page', function () {
      liveSearch.state = { search: 'state' }
      spyOn(liveSearch, 'updateElement')
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state))
      expect(liveSearch.updateElement).toHaveBeenCalled()
    })
  })

  it('should show the filter results button if the GOVUK.support.history returns false', function () {
    // Hide the filter button (this is done in the CSS under the .js-enabled selector normally)
    $form.find('.js-live-search-fallback').hide()
    expect($form.find('.js-live-search-fallback').is(':visible')).toBe(false)
    GOVUK.support.history = function () { return false }
    liveSearch = new GOVUK.LiveSearch({ $form: $form, $results: $results })
    expect($form.find('.js-live-search-fallback').is(':visible')).toBe(true)
  })

  describe('with relevant DOM nodes set', function () {
    beforeEach(function () {
      liveSearch.$form = $form
      liveSearch.$resultsBlock = $results
      liveSearch.$countBlock = $count
      liveSearch.state = { field: 'sheep', published_at: '2004' }
      liveSearch.$atomAutodiscoveryLink = $atomAutodiscoveryLink
    })

    it('should update save state and update results when checkbox is changed', function () {
      var promise = jasmine.createSpyObj('promise', ['done'])
      spyOn(liveSearch, 'updateResults').and.returnValue(promise)
      $form.find('input[name="field"]').prop('checked', false)

      liveSearch.formChange()
      expect(liveSearch.state).toEqual([{ name: 'published_at', value: '2004' }])
      expect(liveSearch.updateResults).toHaveBeenCalled()
    })

    it('should call updateLinks function when a facet is changed', function () {
      spyOn(liveSearch, 'updateLinks')
      $form.find('input[name="field"]').prop('checked', false)

      liveSearch.formChange()
      expect(liveSearch.state).toEqual([{ name: 'published_at', value: '2004' }])
      expect(liveSearch.updateLinks).toHaveBeenCalled()
    })

    it('should trigger analytics trackpage when checkbox is changed', function () {
      var promise = jasmine.createSpyObj('promise', ['done'])
      spyOn(liveSearch, 'updateResults').and.returnValue(promise)
      spyOn(GOVUK.SearchAnalytics, 'trackPageview')
      spyOn(liveSearch, 'trackingInit')

      liveSearch.state = []

      liveSearch.formChange()
      promise.done.calls.mostRecent().args[0]()

      expect(liveSearch.trackingInit).toHaveBeenCalled()
      expect(GOVUK.SearchAnalytics.trackPageview).toHaveBeenCalled()
      var trackArgs = GOVUK.SearchAnalytics.trackPageview.calls.first().args[0]
      expect(trackArgs.split('?')[1], 'field=sheep')
    })

    it("should do nothing if state hasn't changed when a checkbox is changed", function () {
      spyOn(liveSearch, 'updateResults')

      liveSearch.formChange()

      expect(liveSearch.state).toEqual({ field: 'sheep', published_at: '2004' })
      expect(liveSearch.updateResults).not.toHaveBeenCalled()
    })

    it('should trigger filterClicked custom event when input type is text and analytics are not suppressed', function () {
      GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent = function (event) {}
      spyOn(GOVUK.LiveSearch.prototype, 'fireTextAnalyticsEvent')

      $form.find('input[name="published_at"]').val('2005').trigger('change')

      expect(GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent).toHaveBeenCalledTimes(1)
    })

    it('should trigger filterClicked for both change and enter key events on text input', function () {
      GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent = function (event) {}
      spyOn(GOVUK.LiveSearch.prototype, 'fireTextAnalyticsEvent')

      $form.find('input[name="published_at"]').val('searchChange').trigger('change')

      expect(GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent).toHaveBeenCalledTimes(1)

      var enterKeyPress = $.Event('keypress', { keyCode: 13 })
      $form.find('input[name="published_at"]').val('searchEnter').trigger(enterKeyPress)

      expect(GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent).toHaveBeenCalledTimes(2)
    })

    it('should not trigger multiple tracking events if the search term stays the same', function () {
      GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent = function (event) {}
      spyOn(GOVUK.LiveSearch.prototype, 'fireTextAnalyticsEvent')

      $form.find('input[name="published_at"]').val('same term').trigger('change')
      $form.find('input[name="published_at"]').val('same term').trigger('change')

      var enterKeyPress = $.Event('keypress', { keyCode: 13 })
      $form.find('input[name="published_at"]').val('same term').trigger(enterKeyPress)

      expect(GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent).toHaveBeenCalledTimes(1)
    })

    it('should not trigger filterClicked custom event when input type is text and analytics are suppressed', function () {
      GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent = function (event) {}
      spyOn(GOVUK.LiveSearch.prototype, 'fireTextAnalyticsEvent')

      $form.find('input[name="published_at"]').val('2005').trigger({
        type: 'change',
        suppressAnalytics: true
      })

      expect(GOVUK.LiveSearch.prototype.fireTextAnalyticsEvent).toHaveBeenCalledTimes(0)
    })

    it('should display results from the cache', function () {
      liveSearch.resultCache['the=first'] = dummyResponse
      liveSearch.state = { the: 'first' }
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state))
      expect($results.find('a').text()).toMatch('Test report')
      expect($count.text()).toMatch(/^\s*1\s*/)
    })

    it('should update the Atom autodiscovery link', function () {
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state))
      expect($atomAutodiscoveryLink.attr('href')).toEqual(dummyResponse.atom_url)
    })
  })

  describe('popState', function () {
    var dummyHistoryState

    beforeEach(function () {
      dummyHistoryState = { originalEvent: { state: true } }
    })

    it('should call restoreBooleans, restoreTextInputs, saveState and updateResults if there is an event in the history', function () {
      spyOn(liveSearch, 'restoreBooleans')
      spyOn(liveSearch, 'restoreTextInputs')
      spyOn(liveSearch, 'saveState')
      spyOn(liveSearch, 'updateResults')

      liveSearch.popState(dummyHistoryState)

      expect(liveSearch.restoreBooleans).toHaveBeenCalled()
      expect(liveSearch.restoreTextInputs).toHaveBeenCalled()
      expect(liveSearch.saveState).toHaveBeenCalled()
      expect(liveSearch.updateResults).toHaveBeenCalled()
    })
  })

  describe('restoreBooleans', function () {
    beforeEach(function () {
      liveSearch.state = [{ name: 'list_1[]', value: 'checkbox_1' }, { name: 'list_1[]', value: 'checkbox_2' }, { name: 'list_2[]', value: 'radio_1' }]
      liveSearch.$form = $('<form action="/somewhere" class="js-live-search-form"><input id="check_1" type="checkbox" name="list_1[]" value="checkbox_1"><input type="checkbox" id="check_2"  name="list_1[]" value="checkbox_2"><input type="radio" id="radio_1"  name="list_2[]" value="radio_1"><input type="radio" id="radio_2"  name="list_2[]" value="radio_2"><input type="submit"/></form>')
    })

    it('should check a checkbox if in the state it is checked in the history', function () {
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(0)
      liveSearch.restoreBooleans()
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(2)
    })

    it('should not check all the checkboxes if only one is checked', function () {
      liveSearch.state = [{ name: 'list_1[]', value: 'checkbox_2' }]
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(0)
      liveSearch.restoreBooleans()
      expect(liveSearch.$form.find('input[type=checkbox]:checked')[0].id).toBe('check_2')
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(1)
    })

    it('should pick a radiobox if in the state it is picked in the history', function () {
      expect(liveSearch.$form.find('input[type=radio]:checked').length).toBe(0)
      liveSearch.restoreBooleans()
      expect(liveSearch.$form.find('input[type=radio]:checked').length).toBe(1)
    })
  })

  describe('restoreKeywords', function () {
    beforeEach(function () {
      liveSearch.state = [{ name: 'text_1', value: 'Monday' }]
      liveSearch.$form = $('<form action="/somewhere"><input id="text_1" type="text" name="text_1"><input id="text_2" type="text" name="text_2"></form>')
    })

    it('should put the right text back in the right box', function () {
      expect(liveSearch.$form.find('#text_1').val()).toBe('')
      expect(liveSearch.$form.find('#text_2').val()).toBe('')
      liveSearch.restoreTextInputs()
      expect(liveSearch.$form.find('#text_1').val()).toBe('Monday')
      expect(liveSearch.$form.find('#text_2').val()).toBe('')
    })
  })

  describe('indexTrackingData', function () {
    var groupedResponse = {
      'search_results':
        '<ul class="finder-results js-finder-results" data-module="track-click">' +
          '<li class="filtered-results__group">' +
            '<h2 class="filtered-results__facet-heading">Primary group</h2>' +
            '<ol class="gem-c-document-list">' +
              '<li class="gem-c-document-list__item ">' +
                '<a data-track-category="navFinderLinkClicked" data-track-action="foo" data-track-label="" class="gem-c-document-list__item-title " href="/reports/test-report-1">Test report 1</a>' +
                '<ul class="gem-c-document-list__item-metadata"></ul>' +
              '</li>' +
              '<li class="gem-c-document-list__item ">' +
                '<a data-track-category="navFinderLinkClicked" data-track-action="foo" data-track-label="" class="gem-c-document-list__item-title " href="/reports/test-report-4">Test report 4</a>' +
                '<ul class="gem-c-document-list__item-metadata"></ul>' +
              '</li>' +
            '</ol>' +
          '</li>' +
          '<li class="filtered-results__group">' +
            '<h2 class="filtered-results__facet-heading">Default group</h2>' +
            '<ol class="gem-c-document-list">' +
              '<li class="gem-c-document-list__item ">' +
                '<a data-track-category="navFinderLinkClicked" data-track-action="foo" data-track-label="" class="gem-c-document-list__item-title " href="/reports/test-report-3">Test report 3</a>' +
                '<ul class="gem-c-document-list__item-metadata"></ul>' +
              '</li>' +
              '<li class="gem-c-document-list__item ">' +
                '<a data-track-category="navFinderLinkClicked" data-track-action="foo" data-track-label="" class="gem-c-document-list__item-title " href="/reports/test-report-2">Test report 2</a>' +
                '<ul class="gem-c-document-list__item-metadata"></ul>' +
              '</li>' +
            '</ol>' +
          '</li>' +
        '</ul>'
    }

    beforeEach(function () {
      liveSearch.$form = $form
      liveSearch.$resultsBlock = $results
      liveSearch.state = { search: 'state' }
    })

    it('is called by trackingInit()', function () {
      spyOn(liveSearch, 'indexTrackingData')
      liveSearch.trackingInit()
      expect(liveSearch.indexTrackingData).toHaveBeenCalled()
    })

    it('re-indexes tracking actions for grouped items', function () {
      liveSearch.displayResults(groupedResponse, $.param(liveSearch.state))
      liveSearch.indexTrackingData()

      var $firstGroup = $results.find('.filtered-results__group:nth-child(1)')
      var $defaultGroup = $results.find('.filtered-results__group:nth-child(2)')

      expect($firstGroup.find('h2').text()).toMatch('Primary group')
      expect($firstGroup.find('a[data-track-action="foo.1.1"]').text()).toMatch('Test report 1')
      expect($firstGroup.find('a[data-track-action="foo.1.2"]').text()).toMatch('Test report 4')

      expect($defaultGroup.find('h2').text()).toMatch('Default group')
      expect($defaultGroup.find('a[data-track-action="foo.2.1"]').text()).toMatch('Test report 3')
      expect($defaultGroup.find('a[data-track-action="foo.2.2"]').text()).toMatch('Test report 2')
    })
  })

  it('should replace links with new links when state changes', function () {
    liveSearch.updateLinks()
    expect(liveSearch.$emailLink.attr('href')).toBe('https://a-url/email-signup?field=sheep&published_at=2004')
    expect(liveSearch.$atomLink.attr('href')).toBe('http://an-atom-url.atom?field=sheep&published_at=2004')
    expect(liveSearch.$atomAutodiscoveryLink.attr('href')).toBe('http://an-atom-url.atom?field=sheep&published_at=2004')
    $form.find('input[name="field"]').prop('checked', false)
    liveSearch.saveState()
    liveSearch.updateLinks()
    expect(liveSearch.$emailLink.attr('href')).toBe('https://a-url/email-signup?published_at=2004')
    expect(liveSearch.$atomLink.attr('href')).toBe('http://an-atom-url.atom?published_at=2004')
    expect(liveSearch.$atomAutodiscoveryLink.attr('href')).toBe('http://an-atom-url.atom?published_at=2004')
  })

  describe('updateSortOptions', function () {
    it('replaces the sort options with new data', function () {
      liveSearch.$form = $form
      liveSearch.$resultsBlock = $results
      liveSearch.state = { search: 'state' }

      expect($('#order option').length).toBe(2)
      $('#order').remove()
      expect($('#order option').length).toBe(0)
      // We receive new data, which adds the sort options to the DOM.
      liveSearch.updateSortOptions(responseWithSortOptions, $.param(liveSearch.state))
      expect($('#order option').length).toBe(2)
      expect($('#order option:disabled').length).toBe(1)
      expect($('#order option:selected').length).toBe(1)
    })
  })

  describe('spelling suggestions', function () {
    var $suggestionBlock = $('<div class="spelling-suggestions" id="js-spelling-suggestions"></div>')
    var responseWithSpellingSuggestions = {
      'display_total': 1,
      'pluralised_document_noun': 'reports',
      'applied_filters': " \u003Cstrong\u003ECommercial - rotorcraft \u003Ca href='?format=json\u0026keywords='\u003E×\u003C/a\u003E\u003C/strong\u003E",
      'atom_url': 'http://an-atom-url.atom?some-query-param',
      'documents': [
        {
          'document': {
            'title': 'Test report',
            'slug': 'aaib-reports/test-report',
            'metadata': [
              {
                'label': 'Aircraft category',
                'value': 'General aviation - rotorcraft',
                'is_text': true
              }, {
                'label': 'Report type',
                'value': 'Annual safety report',
                'is_text': true
              }, {
                'label': 'Occurred',
                'is_date': true,
                'machine_date': '2013-11-03',
                'human_date': '3 November 2013'
              }
            ]
          },
          'document_index': 1
        }
      ],
      'search_results': '<div class="finder-results js-finder-results" data-module="track-click">' +
        '<ol class="gem-c-document-list">' +
          '<li class="gem-c-document-list__item">' +
            '<a data-track-category="navFinderLinkClicked" data-track-action="" data-track-label="" class="gem-c-document-list__item-title" href="aaib-reports/test-report">Test report</a>' +
              '<p class="gem-c-document-list__item-description">The English business survey will provide Ministers and officials with information about the current economic and business conditions across</p>' +
              '<ul class="gem-c-document-list__item-metadata">' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Document type: Official Statistics' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Part of a collection: English business survey' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Organisation: Closed organisation: Department for Business, Innovation &amp; Skills' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Updated: <time datetime="2012-12-21">21 December 2012</time>' +
                  '</li>' +
              '</ul>' +
          '</li>' +
        '</ol>' +
      '</div>',
      'suggestions': '<p class="govuk-body">Did you mean' +
      '<a class="govuk-link govuk-!-font-weight-bold" data-ecommerce-content-id="dd395436-9b40-41f3-8157-740a453ac972"' +
      'data-ecommerce-row="1" data-track-options="{"dimension81":"driving licences"}" href="/search/all?keywords=driving+licences&order=relevance">' +
      'driving licences</a> </p>'
    }

    var responseWithNoSpellingSuggestions = {
      'display_total': 1,
      'pluralised_document_noun': 'reports',
      'applied_filters': " \u003Cstrong\u003ECommercial - rotorcraft \u003Ca href='?format=json\u0026keywords='\u003E×\u003C/a\u003E\u003C/strong\u003E",
      'atom_url': 'http://an-atom-url.atom?some-query-param',
      'documents': [
        {
          'document': {
            'title': 'Test report',
            'slug': 'aaib-reports/test-report',
            'metadata': [
              {
                'label': 'Aircraft category',
                'value': 'General aviation - rotorcraft',
                'is_text': true
              }, {
                'label': 'Report type',
                'value': 'Annual safety report',
                'is_text': true
              }, {
                'label': 'Occurred',
                'is_date': true,
                'machine_date': '2013-11-03',
                'human_date': '3 November 2013'
              }
            ]
          },
          'document_index': 1
        }
      ],
      'search_results': '<div class="finder-results js-finder-results" data-module="track-click">' +
        '<ol class="gem-c-document-list">' +
          '<li class="gem-c-document-list__item">' +
            '<a data-track-category="navFinderLinkClicked" data-track-action="" data-track-label="" class="gem-c-document-list__item-title" href="aaib-reports/test-report">Test report</a>' +
              '<p class="gem-c-document-list__item-description">The English business survey will provide Ministers and officials with information about the current economic and business conditions across</p>' +
              '<ul class="gem-c-document-list__item-metadata">' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Document type: Official Statistics' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Part of a collection: English business survey' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Organisation: Closed organisation: Department for Business, Innovation &amp; Skills' +
                  '</li>' +
                  '<li class="gem-c-document-list__attribute">' +
                      'Updated: <time datetime="2012-12-21">21 December 2012</time>' +
                  '</li>' +
              '</ul>' +
          '</li>' +
        '</ol>' +
      '</div>',
      'suggestions': ''
    }
    beforeEach(function () {
      $form.append($suggestionBlock)
      liveSearch = new GOVUK.LiveSearch({ $form: $form, $results: $results, $suggestionBlock: $suggestionBlock, $atomAutodiscoveryLink: $atomAutodiscoveryLink })
    })

    afterEach(function () {
      $form.remove()
    })

    it('are shown if there are available in the data', function () {
      liveSearch.state = { search: 'state' }
      liveSearch.displayResults(responseWithSpellingSuggestions, $.param(liveSearch.state))
      expect($('#js-spelling-suggestions a').text()).toBe('driving licences')
      expect($('#js-spelling-suggestions a').attr('href')).toBe('/search/all?keywords=driving+licences&order=relevance')
    })

    it('are not shown if there are none in the data', function () {
      liveSearch.state = { search: 'state' }
      liveSearch.displayResults(responseWithNoSpellingSuggestions, $.param(liveSearch.state))
      expect($('#js-spelling-suggestions').text()).toBe('')
    })

    it('tracking has been called', function () {
      liveSearch.state = { search: 'state' }
      spyOn(liveSearch, 'trackSpellingSuggestionsImpressions')
      liveSearch.displayResults(responseWithSpellingSuggestions, $.param(liveSearch.state))
      expect(liveSearch.trackSpellingSuggestionsImpressions).toHaveBeenCalled()
    })
  })
})
