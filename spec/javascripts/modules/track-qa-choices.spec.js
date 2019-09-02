/* eslint-env jasmine, jquery */

var $ = window.jQuery

describe('QA choices tracker', function () {
  var GOVUK = window.GOVUK || {}
  var tracker
  var $element

  beforeEach(function () {
    spyOn(GOVUK.SearchAnalytics, 'trackEvent')

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
    GOVUK.SearchAnalytics.trackEvent.calls.reset()
  })

  it('tracks checked checkboxes when clicking submit', function () {
    $element.find('input[value="accommodation"]').trigger('click')
    $element.find('input[value="construction"]').trigger('click')
    $element.find('form').trigger('submit')

    expect(GOVUK.SearchAnalytics.trackEvent).toHaveBeenCalledWith(
      'QA option chosen', 'accommodation', { transport: 'beacon', label: 'sector_business_area' }
    )
    expect(GOVUK.SearchAnalytics.trackEvent).toHaveBeenCalledWith(
      'QA option chosen', 'construction', { transport: 'beacon', label: 'sector_business_area' }
    )
  })

  it('track event triggered when no choice is made', function () {
    $element.find('form').trigger('submit')

    expect(GOVUK.SearchAnalytics.trackEvent).toHaveBeenCalledWith(
      'QA option chosen', 'no choice', { transport: 'beacon', label: 'sector_business_area' }
    )
  })
})
