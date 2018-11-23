/* global describe beforeEach it spyOn expect */

var $ = window.jQuery

describe('QA choices tracker', function () {

  var GOVUK = window.GOVUK || {}
  var tracker
  var $element

  GOVUK.analytics = GOVUK.analytics || {}

  beforeEach(function () {
    GOVUK.analytics.trackEvent = function () {}
    spyOn(GOVUK.analytics, 'trackEvent')

    $element = $(
      '<div>' +
        '<form onsubmit="event.preventDefault()">' +
          '<input name="sector_business_area[]" type="checkbox" value="construction">' +
          '<input name="sector_business_area[]" type="checkbox" value="accommodation">' +
          '<input name="sector_business_area[]" type="checkbox" value="furniture">' +
          '<button type="submit">Next</button>' +
        '</form>' +
      '</div>'
    )

    tracker = new GOVUK.Modules.TrackQaChoices()
    tracker.start($element)
  })

  afterEach(function () {
    GOVUK.analytics.trackEvent.calls.reset()
  })

  it('tracks checked checkboxes when clicking submit', function () {
    $element.find('input[value="accommodation"]').trigger('click')
    $element.find('input[value="construction"]').trigger('click')
    $element.find('form').trigger('submit')

    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'QA option chosen', 'accommodation', { transport: 'beacon', label: 'sector_business_area' }
    )
    expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
      'QA option chosen', 'construction', { transport: 'beacon', label: 'sector_business_area' }
    )
  })

  it('does not track events when no choice is made', function () {
    $element.find('form').trigger('submit')

    expect(GOVUK.analytics.trackEvent).not.toHaveBeenCalled()
  })
})
