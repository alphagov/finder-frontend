/* eslint-env jasmine, jquery */

describe('attachCrossDomainTrackerToInput', function () {
  var form
  var tracker
  var linker
  var GOVUK = window.GOVUK || {}

  beforeEach(function () {
    form = $('<form method="POST" action="/somewhere" class="account-signup">' +
               '<input type="hidden" name="key" value="value" />' +
               '<button type="submit">Create a GOV.UK account</button>' +
             '</form>')

    window.ga = {
      getAll: function () {}
    }

    window.gaplugins = {
      Linker: function () {}
    }

    linker = {
      decorate: function () {}
    }

    spyOn(window.ga, 'getAll').and.returnValue([])
    spyOn(window.gaplugins, 'Linker').and.returnValue(linker)
    spyOn(linker, 'decorate').and.returnValue('/somewhere?_ga=abc123')
  })

  afterEach(function () {
    form.remove()
  })

  it('leaves the form action unchanged if ga is not present', function () {
    tracker = []
    GOVUK.attachCrossDomainTrackerToInput(form, tracker)
    expect(form.attr('action')).toEqual('/somewhere')
  })

  it('leaves the form action if unchanged there are no trackers in ga', function () {
    tracker = []
    GOVUK.attachCrossDomainTrackerToInput(form, tracker)
    expect(form.attr('action')).toEqual('/somewhere')
  })

  it('modifies the form action to append ids from ga to the destination url', function () {
    tracker = [{ ga_mock: 'foobar' }]
    GOVUK.attachCrossDomainTrackerToInput(form, tracker)
    expect(form.attr('action')).toEqual('/somewhere?_ga=abc123')
  })
})
