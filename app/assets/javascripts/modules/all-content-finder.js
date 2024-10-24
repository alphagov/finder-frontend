window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  // Enhances the all content finder with dynamic behaviour and analytics tracking
  class AllContentFinder {
    constructor ($module) {
      this.$module = $module

      this.$form = $module.querySelector('.js-all-content-finder-form')
      this.$keywordInput = this.$form.querySelector('input[type="search"]')
      this.$taxonomySelect = $module.querySelector('.js-all-content-finder-taxonomy-select')

      this.initialKeywords = this.$keywordInput.value

      this.defaultSortOrders = ['relevance', 'most-viewed']
    }

    init () {
      this.setupTaxonomySelect()
      this.setupFormDataCleaner()

      if (this.userHasConsentedToAnalytics()) {
        this.setupAnalyticsTracking()
      } else {
        // Allow tracking of events as soon as user consents, not just at next page reload
        window.addEventListener('cookie-consent', () => this.setupAnalyticsTracking())
      }
    }

    userHasConsentedToAnalytics () {
      return GOVUK.getConsentCookie() && GOVUK.getConsentCookie().usage
    }

    setupTaxonomySelect () {
      const taxonomySelect = new GOVUK.TaxonomySelect({ $el: this.$taxonomySelect })
      taxonomySelect.update() // Taxonomy select needs an initial update on setup

      this.$taxonomySelect.addEventListener('change', () => taxonomySelect.update())
    }

    // A best effort, progressive enhancement to keep URLs aesthetically pleasing and easier to
    // manage in terms of analytics by removing empty fields and default sort order from the form
    // data on submission (so they don't clutter up the query parameters)
    setupFormDataCleaner () {
      this.$form.addEventListener('formdata', (e) => {
        const keysToRemove = [...e.formData]
          .filter(([key, value]) =>
            value === '' ||
            value === null ||
            (key === 'order' && this.defaultSortOrders.includes(value))
          ).map(([key]) => key)

        keysToRemove.forEach(key => e.formData.delete(key))
      })
    }

    // Sends the canonical GOV.UK `search` analytics event (the legacy UI does this on change using
    // the regular GA4 finder tracker, but we want this to only happen on submission if the keywords
    // have actually changed since the least search (i.e. page load/module initialisation), so
    // cannot leverage that)
    setupFormSubmissionAnalyticsEvent () {
      this.$form.addEventListener('submit', () => {
        if (this.$keywordInput.value === this.initialKeywords) return

        const schemas = new window.GOVUK.analyticsGa4.Schemas()
        const data = schemas.mergeProperties({
          type: 'finder',
          event_name: 'search',
          section: 'Search',
          action: 'search',
          // standardiseSearchTerm returns undefined for empty strings, which we do _not_ want in
          // this scenario as it would lead to the analytics tracking not picking up on the change
          text: GOVUK.analyticsGa4.core.trackFunctions.standardiseSearchTerm(
            this.$keywordInput.value
          ) || '',
          url: window.location.pathname
        }, 'event_data')

        GOVUK.analyticsGa4.core.sendData(data)
      })
    }

    setupAnalyticsTracking () {
      GOVUK.analyticsGa4.Ga4EcommerceTracker.init()

      this.setupFormSubmissionAnalyticsEvent()
      this.$form.addEventListener('change', (event) => {
        const $closestCategoryWrapper = event.target.closest('[data-ga4-change-category]')

        if ($closestCategoryWrapper) {
          const category = $closestCategoryWrapper.getAttribute('data-ga4-change-category')
          GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent(event.target, category)
        }
      })
    }
  }

  Modules.AllContentFinder = AllContentFinder
})(window.GOVUK.Modules)
