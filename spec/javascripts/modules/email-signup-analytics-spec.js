/* eslint-env browser, jasmine */
/* global GOVUK */

describe('Email subscription button tracking', function () {
  window.GOVUK = window.GOVUK || {}
  window.GOVUK.Modules = window.GOVUK.Modules || {}

  var $element

  beforeEach(function () {
    GOVUK.analytics = {
      trackPageview: function () { },
      trackEvent: function () { },
      setDimension: function () {}
    }

    spyOn(GOVUK.analytics, 'trackEvent')

    $element = document.createElement('button')
    $element.className = '.js-subscribe-button-tracker'
    var buttonText = document.createTextNode('subscribe-button')
    $element.appendChild(buttonText)

    var tracker = new GOVUK.Modules.EmailSignupAnalytics()

    var params = {
      $button: $element,
      'action': 'subscribe',
      'category': 'transition-email-alert'
    }

    tracker.trackSubscriptions(params)
  })

  afterEach(function () {
    GOVUK.analytics.trackEvent.calls.reset()
  })

  it('tracks the Subscribe button was clicked', function () {
    $element.click()

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'Subscribe button clicked', 'subscribe', { 'category': 'transition-email-alert' }
    )
  })
})
