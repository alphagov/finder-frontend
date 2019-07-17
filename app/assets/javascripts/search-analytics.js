(function (global, GOVUK) {
  'use strict'

  window.GOVUK = window.GOVUK || {}

  function canTrack () {
    return !!GOVUK.analytics
  }

  // The SearchAnalytics module is a wrapper around GOVUK.analytics
  GOVUK.SearchAnalytics = {
    trackEvent: function trackEvent () {
      if (!canTrack() || !GOVUK.analytics.trackEvent) { return }
      return GOVUK.analytics.trackEvent.apply(GOVUK, arguments)
    },

    trackPageview: function trackPageview () {
      if (!canTrack() || !GOVUK.analytics.trackPageview) { return }
      return GOVUK.analytics.trackPageview.apply(GOVUK, arguments)
    },

    setDimension: function setDimension () {
      if (!canTrack() || !GOVUK.analytics.setDimension) { return }
      return GOVUK.analytics.setDimension.apply(GOVUK, arguments)
    }
  }
})(window, window.GOVUK)
