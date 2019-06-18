/* eslint-env jquery */
(function () {
  'use strict'

  window.GOVUK = window.GOVUK || {}
  var GOVUK = window.GOVUK

  function LiveSearch (options) {
    this.state = false
    this.previousState = false
    this.resultCache = {}

    this.$form = options.$form
    this.$resultsBlock = options.$results.find('#js-results')
    this.$countBlock = options.$results.find('#js-result-count')
    this.$facetTagBlock = options.$results.find('#js-facet-tag-wrapper')
    this.$loadingBlock = options.$results.find('#js-loading-message')
    this.$sortBlock = options.$results.find('#js-sort-options')
    this.$paginationBlock = options.$results.find('#js-pagination')
    this.action = this.$form.attr('action') + '.json'
    this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink
    this.baseTitle = $("meta[name='govuk:base_title']").attr('content') || document.title
    this.$emailLink = $('a[href*="email-signup"]')
    this.previousSearchTerm = ''

    this.emailSignupHref = this.$emailLink.attr('href')
    this.$atomLink = $('a[href*=".atom"]')
    this.atomHref = this.$atomLink.attr('href')
    this.bindSortElements()
    this.getTaxonomyFacet().update()

    if (GOVUK.support.history()) {
      this.saveState()

      this.$form.on('change', 'input[type=checkbox], input[type=radio], select',
        function (e) {
          this.formChange(e)
        }.bind(this)
      )

      this.$form.on('change keypress', 'input[type=text],input[type=search]',
        function (e) {
          var ENTER_KEY = 13

          if (e.keyCode === ENTER_KEY || e.type === 'change') {
            if (e.currentTarget.value !== this.previousSearchTerm && !e.suppressAnalytics) {
              LiveSearch.prototype.fireTextAnalyticsEvent(e)
            }
            this.formChange(e)
            this.previousSearchTerm = e.currentTarget.value
            e.preventDefault()
          }
        }.bind(this)
      )

      this.indexTrackingData()

      $(window).on('popstate', this.popState.bind(this))
    } else {
      this.$form.find('.js-live-search-fallback').show()
    }
  }

  LiveSearch.prototype.getTaxonomyFacet = function getTaxonomyFacet () {
    this.taxonomy = this.taxonomy || new GOVUK.TaxonomySelect({ $el: $('.app-taxonomy-select') })
    return this.taxonomy
  }

  LiveSearch.prototype.getSerializeForm = function getSerializeForm () {
    var uncleanState = this.$form.serializeArray()
    return uncleanState.filter(function (field) { return field.name !== 'option-select-filter' })
  }

  LiveSearch.prototype.saveState = function saveState (state) {
    if (typeof state === 'undefined') {
      state = this.getSerializeForm()
    }
    this.previousState = this.state
    this.state = state
  }

  LiveSearch.prototype.popState = function popState (event) {
    if (event.originalEvent.state) {
      this.saveState(event.originalEvent.state)
      this.updateOrder()
      this.updateResults()
      this.restoreBooleans()
      this.restoreTextInputs()
    }
  }

  LiveSearch.prototype.formChange = function formChange (e) {
    var pageUpdated
    if (this.isNewState()) {
      this.getTaxonomyFacet().update()
      this.saveState()
      this.updateOrder()
      this.updateLinks()
      this.updateTitle()
      pageUpdated = this.updateResults()
      pageUpdated.done(
        function () {
          var newPath = window.location.pathname + '?' + $.param(this.state)
          window.history.pushState(this.state, '', newPath)
          this.trackingInit()
          this.setRelevantResultCustomDimension()
          this.trackPageView()
        }.bind(this)
      )
    }
  }

  LiveSearch.prototype.setRelevantResultCustomDimension = function setRelevantResultCustomDimension () {
    if (this.canSetCustomDimension()) {
      var $mostRelevantDocumentLink = $('.js-finder-results').find('.document__link--top')
      var dimensionValue = $mostRelevantDocumentLink.length ? 'yes' : 'no'
      GOVUK.analytics.setDimension(83, dimensionValue)
    }
  }

  LiveSearch.prototype.trackingInit = function trackingInit () {
    GOVUK.modules.start($('.js-live-search-results-block'))
    this.indexTrackingData()
  }

  LiveSearch.prototype.trackPageView = function trackPageView () {
    if (this.canTrackPageview()) {
      var newPath = window.location.pathname + '?' + $.param(this.state)
      GOVUK.analytics.trackPageview(newPath)
    }
  }

  /**
   * Results grouped by facet and facet value do not have an accurate document index
   * due to the post-search sorting and grouping which the presenter performs.
   * In this case (ie. sorted by 'Topic' which actually means group by facet, facet value),
   * rewrite the appropriate tracking data attribute to delineate the group and document index.
   */
  LiveSearch.prototype.indexTrackingData = function indexTrackingData () {
    var $groupEls = $('.filtered-results__group')
    if ($groupEls.length > 0) {
      $groupEls.each(function (groupIndex) {
        var $resultEls = $(this).find('.document')
        $resultEls.each(function (documentIndex) {
          var $document = $(this)
          var $documentLink = $document.find('a')
          var trackingAction = $documentLink.attr('data-track-action')
          trackingAction = trackingAction.replace(/\.\d+$/, '')
          trackingAction = [trackingAction, groupIndex + 1, documentIndex + 1].join('.')
          $documentLink.attr('data-track-action', trackingAction)
        })
      })
    }

    var $results = $('.js-finder-results')
    if ($results.length > 0) {
      var $mostRelevantDocumentLink = $results.find('.document__link--top')

      if ($mostRelevantDocumentLink.length === 1) {
        var trackingAction = $mostRelevantDocumentLink.attr('data-track-action')
        trackingAction += 'r'
        $mostRelevantDocumentLink.attr('data-track-action', trackingAction)
      }
    }
  }

  LiveSearch.prototype.fireTextAnalyticsEvent = function fireTextAnalyticsEvent (event) {
    if (this.canTrackPageview()) {
      var options = {
        transport: 'beacon',
        label: $(event.target)[0].value
      }
      var category = 'filterClicked'
      var action = $('label[for="' + event.target.id + '"]')[0].innerText

      GOVUK.analytics.trackEvent(
        category,
        action,
        options
      )
    }
  }

  LiveSearch.prototype.canTrackPageview = function canTrackPageview () {
    return GOVUK.analytics && GOVUK.analytics.trackPageview
  }

  LiveSearch.prototype.canSetCustomDimension = function canSetCustomDimension () {
    return GOVUK.analytics && GOVUK.analytics.setDimension
  }

  LiveSearch.prototype.cache = function cache (slug, data) {
    if (typeof data === 'undefined') {
      return this.resultCache[slug]
    } else {
      this.resultCache[slug] = data
    }
  }

  LiveSearch.prototype.isNewState = function isNewState () {
    return $.param(this.state) !== $.param(this.getSerializeForm())
  }

  LiveSearch.prototype.updateTitle = function updateTitle () {
    var keywords = this.getTextInputValue('keywords', this.state)
    var keywordsPresent = keywords !== ''

    if (keywordsPresent) {
      document.title = keywords + ' - ' + this.baseTitle
    } else {
      document.title = this.baseTitle
    }
  }

  LiveSearch.prototype.updateSortOptions = function updateSortOptions (results, action) {
    if (action !== $.param(this.state)) { return }
    this.updateElement(this.$sortBlock, results.sort_options_markup)
    this.bindSortElements()
  }

  LiveSearch.prototype.bindSortElements = function bindSortElements () {
    this.$orderSelect = this.$form.find('.js-order-results')
    this.$relevanceOrderOption = this.$orderSelect.find('option[value=' + this.$orderSelect.data('relevance-sort-option') + ']')
    this.$relevanceOrderOptionIndex = this.$relevanceOrderOption.index()
  }

  LiveSearch.prototype.updateOrder = function updateOrder () {
    if (!this.$orderSelect.length) {
      return
    }

    var keywords = this.getTextInputValue('keywords', this.state)
    var previousKeywords = this.getTextInputValue('keywords', this.previousState)

    var keywordsPresent = keywords !== ''
    var previousKeywordsPresent = previousKeywords !== ''
    var keywordsCleared = !keywordsPresent && previousKeywordsPresent

    if (keywordsPresent && !previousKeywordsPresent) {
      this.selectRelevanceSortOption()
    }

    if (keywordsCleared) {
      this.selectDefaultSortOption()
    }
  }

  LiveSearch.prototype.selectDefaultSortOption = function selectDefaultSortOption () {
    var defaultSortOption = this.$orderSelect.data('default-sort-option')

    this.$orderSelect.val(defaultSortOption)
    this.state = this.getSerializeForm()
  }

  LiveSearch.prototype.selectRelevanceSortOption = function selectRelevanceSortOption () {
    var relevanceSortOption = this.$orderSelect.data('relevance-sort-option')
    if (relevanceSortOption) {
      this.$relevanceOrderOption.removeAttr('disabled')
      this.$orderSelect.val(relevanceSortOption)
      this.state = this.getSerializeForm()
    }
  }

  LiveSearch.prototype.updateResults = function updateResults () {
    var searchState = $.param(this.state)
    var cachedResultData = this.cache(searchState)
    var liveSearch = this
    if (typeof cachedResultData === 'undefined') {
      this.showLoadingIndicator()
      return $.ajax({
        url: this.action,
        data: this.state,
        searchState: searchState
      }).done(function (response) {
        liveSearch.cache($.param(liveSearch.state), response)
        liveSearch.displayResults(response, this.searchState)
      }).error(function () {
        liveSearch.showErrorIndicator()
      })
    } else {
      this.displayResults(cachedResultData, searchState)
      var out = new $.Deferred()
      return out.resolve()
    }
  }

  LiveSearch.prototype.updateLinks = function updateLinks () {
    var searchState = '?' + $.param(this.state)
    if (typeof (this.emailSignupHref) !== 'undefined' && this.emailSignupHref != null) {
      this.$emailLink.attr('href', this.emailSignupHref.split('?')[0] + searchState)
    }
    if (typeof (this.atomHref) !== 'undefined' && this.atomHref != null) {
      this.$atomLink.attr('href', this.atomHref.split('?')[0] + searchState)
      this.$atomAutodiscoveryLink.attr('href', this.atomHref.split('?')[0] + searchState)
    }
  }

  LiveSearch.prototype.showLoadingIndicator = function showLoadingIndicator () {
    this.$loadingBlock.text('Loading...').show()
  }

  LiveSearch.prototype.showErrorIndicator = function showErrorIndicator () {
    this.$loadingBlock.text('Error. Please try modifying your search and trying again.')
  }

  LiveSearch.prototype.updateElement = function updateElement (element, content) {
    element.html(content)
  }

  LiveSearch.prototype.displayResults = function displayResults (results, action) {
    // As search is asynchronous, check that the action associated with these results is
    // still the latest to stop results being overwritten by stale data
    if (action === $.param(this.state)) {
      this.updateElement(this.$resultsBlock, results.search_results)
      this.updateElement(this.$facetTagBlock, results.facet_tags)
      this.updateElement(this.$countBlock, results.total)
      this.updateElement(this.$paginationBlock, results.next_and_prev_links)
      this.updateSortOptions(results, action)
      this.$atomAutodiscoveryLink.attr('href', results.atom_url)
      this.$loadingBlock.text('').hide()
    }
  }

  LiveSearch.prototype.restoreBooleans = function restoreBooleans () {
    var that = this
    this.$form.find('input[type=checkbox], input[type=radio]').each(function (i, el) {
      var $el = $(el)
      $el.prop('checked', that.isBooleanSelected($el.attr('name'), $el.attr('value')))
    })
  }

  LiveSearch.prototype.isBooleanSelected = function isBooleanSelected (name, value) {
    var i, _i
    for (i = 0, _i = this.state.length; i < _i; i++) {
      if (this.state[i].name === name && this.state[i].value === value) {
        return true
      }
    }
    return false
  }

  LiveSearch.prototype.restoreTextInputs = function restoreTextInputs () {
    var that = this
    this.$form.find('input[type=text], input[type=search], select').each(function (i, el) {
      var $el = $(el)
      $el.val(that.getTextInputValue($el.attr('name'), that.state))
    })
  }

  LiveSearch.prototype.getTextInputValue = function getTextInputValue (name, state) {
    var i, _i
    for (i = 0, _i = state.length; i < _i; i++) {
      if (state[i].name === name) {
        return state[i].value
      }
    }
    return ''
  }

  GOVUK.LiveSearch = LiveSearch
}())
