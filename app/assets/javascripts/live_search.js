(function () {
  'use strict'

  window.GOVUK = window.GOVUK || {}
  var GOVUK = window.GOVUK

  function LiveSearch (options) {
    this.state = false
    this.previousState = false
    this.resultCache = {}

    this.$form = options.$form
    this.$searchSubmitButton = this.$form.querySelector('.gem-c-search__submit')
    this.$resultsWrapper = this.$form.querySelector('.js-live-search-results-block')
    this.$suggestionsBlock = this.$form.querySelector('#js-spelling-suggestions')
    this.$resultsBlock = options.$results.querySelector('#js-results')
    this.$countBlock = options.$results.querySelector('#js-result-count')
    this.$mobileResultsCount = this.$form.querySelector('.js-result-count')
    this.$selectedFilterCount = this.$form.querySelector('.js-selected-filter-count')
    this.$facetTagBlock = options.$results.querySelector('#js-facet-tag-wrapper')
    this.$mobileFacetTagBlock = this.$form.querySelector('.js-mobile-facet-tag-block')
    this.$loadingBlock = options.$results.querySelector('#js-loading-message')
    this.$sortBlock = options.$results.querySelector('#js-sort-options')
    this.$paginationBlock = options.$results.querySelector('#js-pagination')
    this.action = this.$form.getAttribute('action') + '.json'
    if (options.$atomAutodiscoveryLink) {
      this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink
    }

    this.baseTitle = document.querySelector("meta[name='govuk:base_title']")
    if (this.baseTitle) {
      this.baseTitle = this.baseTitle.getAttribute('content')
    } else {
      this.baseTitle = document.title
    }

    this.$resultsCountMetaTag = document.querySelector("meta[name='govuk:search-result-count']")
    this.$resultsTokenMetaTag = document.querySelector("meta[name='govuk:discovery-engine-attribution-token']")
    this.$emailLinks = document.querySelectorAll('[href*="email-signup"]')
    this.previousSearchTerm = ''

    if (this.$emailLinks[0]) {
      this.emailSignupHref = this.$emailLinks[0].getAttribute('href')
    }
    this.$atomLinks = document.querySelectorAll('[href*=".atom"]')
    if (this.$atomLinks[0]) {
      this.atomHref = this.$atomLinks[0].getAttribute('href')
    }
    this.bindSortElements()
    this.getAndUpdateTaxonomyFacet()

    if (document.readyState === 'complete') {
      this.Ga4EcommerceTracking()
    } else {
      window.addEventListener('DOMContentLoaded', function () {
        this.Ga4EcommerceTracking()
      }.bind(this))
    }

    this.focusErrorMessagesOnLoad(this.$form)

    // prevent page refresh on search submit button click
    // instead trigger the results fetch
    if (this.$searchSubmitButton) {
      this.$searchSubmitButton.addEventListener('click', function (e) {
        e.preventDefault()
        this.formChange(e)
      }.bind(this))
    }

    if (GOVUK.support.history()) {
      this.saveState()

      this.$form.addEventListener('change', function (e) {
        this.formChange(e)
      }.bind(this))

      // custom event listener on the form, that fires the update only once
      // when we clear of filters
      // fired from javascripts/modules/mobile-filters-modal.js
      this.$form.addEventListener('customFormChange', function (e) {
        this.formChange(e)
      }.bind(this))

      this.handleKeyPress = function (e) {
        var ENTER_KEY = 13

        if (e.keyCode === ENTER_KEY || e.type === 'change') {
          // cater for jQuery and native events
          this.formChange(e)
          this.previousSearchTerm = e.currentTarget.value
          e.preventDefault()
        }
      }

      var inputs = this.$form.querySelectorAll('input[type=text],input[type=search]')
      for (var i = 0; i < inputs.length; i++) {
        inputs[i].addEventListener('change', this.handleKeyPress.bind(this))
        inputs[i].addEventListener('keypress', this.handleKeyPress.bind(this))
      }

      document.addEventListener('popstate', this.popState.bind(this))
    } else {
      var fallback = this.$form.querySelector('.js-live-search-fallback')
      fallback.style.display = 'block'
    }
  }

  LiveSearch.prototype.restartGa4EcommerceTracking = function restartGa4EcommerceTracking () {
    if (document.readyState === 'complete') {
      this.Ga4EcommerceTracking(this.previousSearchUrl)
    } else {
      window.addEventListener('DOMContentLoaded', function () {
        this.Ga4EcommerceTracking(this.previousSearchUrl)
      }.bind(this))
    }
  }

  LiveSearch.prototype.reinitialiseGa4Tracking = function reinitialiseGa4Tracking () {
    GOVUK.modules.start(this.$resultsWrapper)
    this.restartGa4EcommerceTracking()
  }

  LiveSearch.prototype.Ga4EcommerceTracking = function (referrer) {
    if (GOVUK.analyticsGa4 && GOVUK.analyticsGa4.Ga4EcommerceTracker) {
      var consentCookie = GOVUK.getConsentCookie()

      if (consentCookie && consentCookie.usage) {
        if (this.$resultsWrapper) {
          this.$resultsWrapper.setAttribute('data-ga4-search-query', this.currentKeywords())
          var sortedBy = this.$resultsWrapper.querySelector('#order')
          // Check that the sortedBy element exists and contains option elements
          if (sortedBy && sortedBy.options.length > 0) {
            this.$resultsWrapper.setAttribute('data-ga4-ecommerce-variant', sortedBy.options[sortedBy.selectedIndex].text)
          }
        }
        GOVUK.analyticsGa4.Ga4EcommerceTracker.init(referrer)
      } else {
        window.addEventListener('cookie-consent', function () {
          GOVUK.analyticsGa4.Ga4EcommerceTracker.init(referrer)
        })
      }
    }
  }

  LiveSearch.prototype.getAndUpdateTaxonomyFacet = function getAndUpdateTaxonomyFacet () {
    var taxonomySelect = document.querySelector('.js-taxonomy-select')
    if (taxonomySelect) {
      this.taxonomy = this.taxonomy || new GOVUK.TaxonomySelect({ $el: taxonomySelect })
      this.taxonomy.update()
    }
  }

  LiveSearch.prototype.getSerializeForm = function getSerializeForm () {
    var formElements = this.$form.elements
    var filtered = []

    for (var i = 0; i < formElements.length; i++) {
      var el = formElements[i]
      if ((el.type && el.type !== 'checkbox' && el.type !== 'radio') || el.checked) {
        var name = el.getAttribute('name')
        var value = el.value
        if (name && value && name !== 'option-select-filter') {
          filtered.push(
            {
              name: name,
              value: value
            }
          )
        }
      }
    }
    return filtered
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
    if (this.isNewState()) {
      this.getAndUpdateTaxonomyFacet()
      this.saveState()
      this.updateOrder()
      this.updateLinks()
      this.updateTitle()
      this.updateResults(e)
    }
  }

  LiveSearch.prototype.serializeState = function (state) {
    var params = []
    var keywords
    if (Array.isArray(state)) {
      for (var i = 0; i < state.length; i++) {
        if (state[i].name === 'keywords') {
          keywords = state[i].value.replace(/\s+/g, '+')
          params.push(state[i].name + '=' + keywords)
        } else {
          params.push(state[i].name + '=' + state[i].value)
        }
      }
    } else {
      for (var key in state) {
        if (Object.prototype.hasOwnProperty.call(state, key)) {
          if (key === 'keywords') {
            keywords = state[key].replace(/\s+/g, '+')
            params.push(encodeURIComponent(key) + '=' + encodeURIComponent(keywords))
          } else {
            params.push(encodeURIComponent(key) + '=' + encodeURIComponent(state[key]))
          }
        }
      }
    }
    return params.join('&')
  }

  LiveSearch.prototype.updateSpellingSuggestionMetaTag = function updateSpellingSuggestionMetaTag () {
    var $spellingSuggestionMetaTag = document.querySelector("meta[name='govuk:spelling-suggestion']")
    if (this.$suggestionsBlock && $spellingSuggestionMetaTag) {
      // currently there's ever only one suggestion
      var spellingSuggestionAvailable = this.$suggestionsBlock.querySelector('a')
      var suggestion = ''
      if (spellingSuggestionAvailable) {
        suggestion = spellingSuggestionAvailable.textContent
      }
      $spellingSuggestionMetaTag.setAttribute('content', suggestion)
    }
  }

  LiveSearch.prototype.cache = function cache (slug, data) {
    if (typeof data === 'undefined') {
      return this.resultCache[slug]
    } else {
      this.resultCache[slug] = data
    }
  }

  LiveSearch.prototype.isNewState = function isNewState () {
    return this.serializeState(this.state) !== this.serializeState(this.getSerializeForm())
  }

  LiveSearch.prototype.updateTitle = function updateTitle () {
    var keywords = this.currentKeywords()
    var keywordsPresent = keywords !== ''

    if (keywordsPresent) {
      document.title = keywords + ' - ' + this.baseTitle
    } else {
      document.title = this.baseTitle
    }
  }

  LiveSearch.prototype.updateMeta = function updateMeta (tag, value) {
    // update search tracking meta data tag with new value
    if (tag) {
      tag.setAttribute('content', value)
    }
  }

  LiveSearch.prototype.updateSortOptions = function updateSortOptions (results, action) {
    if (action !== this.serializeState(this.state)) { return }
    var currentSortOptions = this.$sortBlock.querySelector('select')
    var newSortOptions

    if (results.sort_options_markup) {
      // The select element is removed from results.sort_options_markup in order to retain the original select element. Only the option
      // elements are updated with new markup. This is to prevent focus from being lost on the select element after the user sorts their
      // results.
      newSortOptions = this.removeSelectElement(results.sort_options_markup)
    }

    this.updateElement(currentSortOptions, newSortOptions)
    this.bindSortElements()
  }

  LiveSearch.prototype.removeSelectElement = function removeSelectElement (sortOptionsMarkup) {
    var SELECT_TAG_REGEX = /<\/?select\b[^>]*>/g
    return sortOptionsMarkup.replace(SELECT_TAG_REGEX, '')
  }

  LiveSearch.prototype.bindSortElements = function bindSortElements () {
    this.$orderSelect = this.$form.querySelector('#order')
    if (this.$orderSelect) {
      this.$relevanceOrderOption = this.$orderSelect.querySelector('option[value=' + this.$orderSelect.getAttribute('data-relevance-sort-option') + ']')
    }
  }

  LiveSearch.prototype.currentKeywords = function currentKeywords () {
    return this.getTextInputValue('keywords', this.state)
  }

  LiveSearch.prototype.updateOrder = function updateOrder () {
    if (!this.$orderSelect) {
      return
    }

    var keywords = this.currentKeywords()
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
    var defaultSortOption = this.$orderSelect.getAttribute('data-default-sort-option')

    this.$orderSelect.value = defaultSortOption
    this.state = this.getSerializeForm()
  }

  LiveSearch.prototype.selectRelevanceSortOption = function selectRelevanceSortOption () {
    var relevanceSortOption = this.$orderSelect.getAttribute('data-relevance-sort-option')
    if (relevanceSortOption) {
      this.$relevanceOrderOption.removeAttribute('disabled')
      this.$orderSelect.value = relevanceSortOption
      this.state = this.getSerializeForm()
    }
  }

  LiveSearch.prototype.updateResults = function updateResults (formChangeEvent) {
    var searchState = this.serializeState(this.state)
    var cachedResultData = this.cache(searchState)
    var liveSearch = this
    this.previousSearchUrl = window.location.href

    if (typeof cachedResultData === 'undefined') {
      this.showLoadingIndicator()
      var xhr = new XMLHttpRequest()
      var url = this.action + '?' + encodeURI(searchState)

      var done = function (e) {
        if (xhr.readyState === 4 && xhr.status === 200) {
          var response = JSON.parse(e.target.response)
          liveSearch.updateUrl()
          liveSearch.cache(liveSearch.serializeState(liveSearch.state), response)
          liveSearch.ga4TrackFormChange(formChangeEvent) // must be before displayResults changes the DOM, otherwise will break formChangeEvent.target.closest
          liveSearch.displayResults(response, searchState)
          liveSearch.reinitialiseGa4Tracking()
        } else {
          liveSearch.showErrorIndicator()
        }
      }

      xhr.open('GET', url, true)
      xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
      xhr.addEventListener('load', done)
      xhr.send()
    } else {
      this.updateUrl()
      this.ga4TrackFormChange(formChangeEvent) // must be before displayResults changes the DOM, otherwise will break formChangeEvent.target.closest
      this.displayResults(cachedResultData, searchState)
      this.reinitialiseGa4Tracking()
    }
  }

  LiveSearch.prototype.updateUrl = function () {
    var newPath = encodeURI(window.location.pathname + '?' + this.serializeState(this.state))
    window.history.pushState(this.state, '', newPath)
  }

  LiveSearch.prototype.updateLinks = function updateLinks () {
    var searchState = '?' + this.serializeState(this.state)
    if (typeof (this.emailSignupHref) !== 'undefined' && this.emailSignupHref != null) {
      for (var e = 0; e < this.$emailLinks.length; e++) {
        this.$emailLinks[e].setAttribute('href', encodeURI(this.emailSignupHref.split('?')[0] + searchState))
      }
    }
    if (typeof (this.atomHref) !== 'undefined' && this.atomHref != null) {
      for (var a = 0; a < this.$atomLinks.length; a++) {
        this.$atomLinks[a].setAttribute('href', encodeURI(this.atomHref.split('?')[0] + searchState))
      }
      if (this.$atomAutodiscoveryLink) {
        this.$atomAutodiscoveryLink.setAttribute('href', encodeURI(this.atomHref.split('?')[0] + searchState))
      }
    }
  }

  LiveSearch.prototype.showLoadingIndicator = function showLoadingIndicator () {
    this.$loadingBlock.textContent = 'Loading...'
    this.$loadingBlock.style.display = 'block'
  }

  LiveSearch.prototype.showErrorIndicator = function showErrorIndicator () {
    this.$loadingBlock.textContent = 'Error. Please try modifying your search and trying again.'
  }

  LiveSearch.prototype.updateElement = function updateElement (element, content) {
    if (element) {
      element.innerHTML = content
    }
  }

  LiveSearch.prototype.displayResults = function displayResults (results, action) {
    // As search is asynchronous, check that the action associated with these results is
    // still the latest to stop results being overwritten by stale data
    if (action === this.serializeState(this.state)) {
      this.updateElement(this.$resultsBlock, results.search_results)
      this.updateElement(this.$facetTagBlock, results.facet_tags)
      this.updateElement(this.$countBlock, results.display_total)
      this.updateElement(this.$mobileResultsCount, results.display_total)
      this.updateElement(this.$mobileFacetTagBlock, results.facet_tags)
      this.updateElement(this.$selectedFilterCount, results.display_selected_facets_count)
      this.updateElement(this.$paginationBlock, results.next_and_prev_links)
      this.updateElement(this.$suggestionsBlock, results.suggestions)
      this.updateSpellingSuggestionMetaTag()
      this.updateSortOptions(results, action)
      this.updateMeta(this.$resultsCountMetaTag, results.total)
      this.updateMeta(this.$resultsTokenMetaTag, results.discovery_engine_attribution_token)
      this.manipulateErrorMessages(results.errors)
      if (this.$atomAutodiscoveryLink) {
        this.$atomAutodiscoveryLink.setAttribute('href', results.atom_url)
      }
      this.$loadingBlock.textContent = ''
      this.$loadingBlock.style.display = 'none'
    }
  }

  LiveSearch.prototype.restoreBooleans = function restoreBooleans () {
    var inputs = this.$form.querySelectorAll('input[type=checkbox], input[type=radio]')

    for (var i = 0; i < inputs.length; i++) {
      var $el = inputs[i]
      $el.setAttribute('checked', this.isBooleanSelected($el.getAttribute('name'), $el.value))
    }
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
    var inputsAndSelects = this.$form.querySelectorAll('input[type=text], input[type=search], select')

    for (var i = 0; i < inputsAndSelects.length; i++) {
      var $el = inputsAndSelects[i]
      $el.value = this.getTextInputValue($el.getAttribute('name'), this.state)
    }
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

  LiveSearch.prototype.focusErrorMessagesOnLoad = function ($container) {
    var $inputWithError = $container.querySelector('.govuk-input--error')
    if ($inputWithError) {
      $inputWithError.focus()
    }
  }

  LiveSearch.prototype.manipulateErrorMessages = function (errorsObj) {
    if (!errorsObj) return
    // finders have different date fields
    for (var prop in errorsObj) {
      // store the name of the error item, eg. publictimestamp
      var errorType = prop
      // get true/false value for each to manipulate the error message
      for (var field in errorsObj[prop]) {
        var fieldsObj = errorsObj[prop]
        fieldsObj[field] ? this.renderErrorMessage(errorType, field) : this.removeErrorMessage(errorType, field)
      }
    }
  }

  LiveSearch.prototype.renderErrorMessage = function (type, field) {
    var $input = this.$form.querySelector('input[name*="' + type + '[' + field + ']"]')
    var errorMessageElement = document.createElement('span')
    errorMessageElement.setAttribute('id', 'error-' + type)
    errorMessageElement.setAttribute('class', 'gem-c-error-message govuk-error-message')
    errorMessageElement.innerHTML = '<span class="govuk-visually-hidden">Error:</span> Enter a date'

    var errorMessages = $input.parentNode.querySelectorAll('.gem-c-error-message')
    if (errorMessages.length === 0) {
      $input.classList.add('govuk-input--error')
      $input.insertAdjacentElement('beforebegin', errorMessageElement)
      var parent = $input.parentNode
      if (parent.classList.contains('govuk-form-group')) {
        parent.classList.add('govuk-form-group--error')
      }
      $input.setAttribute('aria-describedby', $input.getAttribute('aria-describedby') + ' ' + errorMessageElement.getAttribute('id'))
    }
    $input.focus()
  }

  LiveSearch.prototype.removeErrorMessage = function (type, field) {
    var $input = this.$form.querySelector('input[name*="' + type + '[' + field + ']"]')
    if ($input) {
      // only remove the message if it's present
      var errorMessages = $input.parentNode.querySelectorAll('.gem-c-error-message')

      if (errorMessages.length > 0) {
        $input.classList.remove('govuk-input--error')
        for (var x = errorMessages.length - 1; x >= 0; x--) {
          errorMessages[x].parentNode.removeChild(errorMessages[x])
        }
        var inputParent = $input.parentNode
        if (inputParent.classList.contains('govuk-form-group')) {
          inputParent.classList.remove('govuk-form-group--error')
        }
        $input.setAttribute('aria-describedby', '')
      }
    }
  }

  LiveSearch.prototype.ga4TrackFormChange = function ga4TrackFormChange (event) {
    if (event) {
      var ga4ChangeCategory = event.target.closest('[data-ga4-change-category]')
      if (ga4ChangeCategory) {
        ga4ChangeCategory = ga4ChangeCategory.getAttribute('data-ga4-change-category')

        if (GOVUK.analyticsGa4 && GOVUK.analyticsGa4.Ga4FinderTracker) {
          var consentCookie = GOVUK.getConsentCookie()

          if (consentCookie && consentCookie.usage) {
            GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent(event, ga4ChangeCategory)
          }
        }
      }
    }
  }

  GOVUK.LiveSearch = LiveSearch
}())
