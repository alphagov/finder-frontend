/* global XMLHttpRequest */
//= require accessible-autocomplete/dist/accessible-autocomplete.min.js
window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  // message for the user when there are no suggestions
  // or connection failed
  var statusMessage = null
  function Autocomplete () {}

  Autocomplete.prototype.start = function ($module) {
    this.$module = $module[0]
    this.$input = this.$module.querySelector('input')
    this.$label = this.$module.querySelector('label')
    this.$submitButton = this.$module.querySelector('button[type=submit]')
    this.$searchContainer = this.$module.querySelector('.gem-c-search')
    // store user entered partial query for further use
    this.userEnteredQuery = ''
    // use to store suggestions
    this.cachedSuggestions = []

    // prevent autocomplete from running in IE<10 and Android WebKit
    // http://caniuse.com/#feat=pagevisibility
    // autocomplete does support IE9 but we have an additional check for history mode
    // in liveSearch and a fallback submit button that in combination with
    // with accessible autocomplete submits the form and refreshes the page
    var featuresNeeded = (
      'visibilityState' in document
    )

    if (!featuresNeeded) {
      return
    }

    this.initAutoCompleteSearchBox(this.$input, this.$label, this.$submitButton)

    // we have a fallback filter button
    // with accessible autocomplete suggestions we also allow keyword search
    // unfortunately that triggers the form submit and refreshes the page
    var $fallbackSubmitButton = document.querySelector('.js-live-search-fallback button')
    $fallbackSubmitButton.addEventListener('click', function (e) {
      e.preventDefault()
    })
  }

  Autocomplete.prototype.initAutoCompleteSearchBox = function ($input, $label, $submitButton) {
    // a higher helper function to that executes a named function at a specified delay
    // it's used here to only hit the api 300ms after the user finishes typing
    // as we don't need to get results for each character immediately
    // https://web.archive.org/web/20190112051125/https://remysharp.com/2010/07/21/throttling-function-calls/
    function debounce (fn, delay) {
      var timer = null
      return function () {
        var context = this
        var args = arguments
        clearTimeout(timer)
        timer = setTimeout(function () {
          fn.apply(context, args)
        }, delay)
      }
    }

    window.accessibleAutocomplete({ // eslint-disable-line no-new, new-cap
      id: $input.id,
      name: $input.name,
      element: this.$module,
      defaultValue: $input.value || '',
      cssNamespace: 'app-autocomplete-search',
      displayMenu: 'overlay',
      confirmOnBlur: false,
      placeholder: $label.innerText,
      onConfirm: this.handleOnConfirm.bind(this),
      minLength: 3,
      source: debounce(this.handleSearchQuery, 300).bind(this),
      tNoResults: function () { return statusMessage }
    })

    this.enhanceSearchBox(this.$label, $submitButton, this.$searchContainer)
  }

  Autocomplete.prototype.enhanceSearchBox = function ($label, $submitButton, $searchContainer) {
    // as we're removing the old search element we want to keep the old label and text
    // but hide it as we're using the placeholder
    var $labelClone = $label.cloneNode(true)
    $labelClone.className = 'govuk-visually-hidden'

    // we'll place the submit button back so that users
    // are assured this is a search box
    var $submitButtonClone = $submitButton.cloneNode(true)

    // remove the old search box and insert the copy of the label and submit button
    this.$module.removeChild($searchContainer)
    this.$module.insertAdjacentElement('beforebegin', $labelClone)
    this.$module.querySelector('.app-autocomplete-search__wrapper')
      .insertAdjacentElement('afterend', $submitButtonClone)
  }

  Autocomplete.prototype.handleOnConfirm = function (query) {
    // if GA available trigger click event submission on selected suggestion
    this.trackSelectedOption(query)

    // update the form input with the suggestion value the user selected
    var $enhancedInput = this.$module.querySelector('input')
    $enhancedInput.value = query

    // dispatch the custom form change event to trigger the livesearch functionality
    var $form = document.querySelector('.js-live-search-form')
    var customEvent = document.createEvent('HTMLEvents')
    customEvent.initEvent('customFormChange', true, false)
    $form.dispatchEvent(customEvent)
  }

  Autocomplete.prototype.trackSelectedOption = function (query) {
    // built-in onConfirm method only provides acces to the query
    // so we need to find our own index of the selected option
    // by checking for matching query string
    var $availableSuggestionsNodeArray = Array.prototype.slice.call(this.$module.querySelector('.app-autocomplete-search__menu').childNodes)
    // get data from the node to use in tracking
    var trackingDataOptions = {}
    for (var i = 0; i < $availableSuggestionsNodeArray.length; i++) {
      var node = $availableSuggestionsNodeArray[i]
      if (node.innerText === query) {
        trackingDataOptions.text = node.innerText
        trackingDataOptions.position = node.getAttribute('aria-posinset')
        trackingDataOptions.numberOfSuggestions = node.getAttribute('aria-setsize')
        break
      }
    }

    window.GOVUK.SearchAnalytics.trackEvent(
      'suggestionClicked',
      'click',
      {
        'dimension333': this.userEnteredQuery,
        'dimension444': trackingDataOptions.text,
        'dimension555': trackingDataOptions.position,
        'dimension666': trackingDataOptions.numberOfSuggestions
      }
    )
    document.querySelector('meta[name="govuk:publishing-application"]').setAttribute('content', 'suggestion selected')
  }

  Autocomplete.prototype.handleSearchQuery = function (query, populateResults) {
    // Autocomplete is hidden for mobile so don't send a request if the results won't be shown
    var $autocomplete = document.querySelector('.app-autocomplete-search__menu')
    if ($autocomplete.offsetParent === null) {
      populateResults([])
    }

    // Don't show a status message in case the API fails or is scaled down because it's causing problems
    // Ideally, this would be shown but it's (probably) more important to fail gracefully for an A/B test
    // statusMessage = 'Searching...'

    this.userEnteredQuery = query

    // check if current string exists in the cached array
    // if it does exists, return matching items
    var matchingCachedResults = this.cachedSuggestions.filter(function (suggestion) {
      return suggestion.toLowerCase().indexOf(query.toLowerCase()) !== -1
    })

    // if there are no matches in the cached array
    // fetch suggestions from API
    // If source is a function, the arguments are: query: string, populateResults: Function
    // https://github.com/alphagov/accessible-autocomplete#source
    matchingCachedResults.length > 0
      ? populateResults(matchingCachedResults)
      : this.fetchSuggestions(query, populateResults)
  }

  Autocomplete.prototype.fetchSuggestions = function (query, populateResults) {
    var request = new XMLHttpRequest()
    request.open('GET', 'https://search-autocomplete-api.staging.publishing.service.gov.uk/autocomplete_suggestions/' + encodeURIComponent(query), true)
      // Time to wait before giving up fetching the search api
    request.timeout = 5 * 1000
    request.onreadystatechange = function () {
      // XHR client readyState DONE
      if (request.readyState === 4) {
        if (request.status === 200) {
          var response = JSON.parse(request.responseText)
          var suggestions = response.results
          statusMessage = 'No suggestions found'
          cacheSuggestions(suggestions, populateResults)
        }
      }
    }
    request.send()
    // cache suggestions to minimise API calls
    var cacheSuggestions = function (suggestions, populateResults) {
      this.cachedSuggestions = suggestions
      populateResults(suggestions)
    }.bind(this)
  }

  Modules.Autocomplete = Autocomplete
})(window.GOVUK.Modules)
