/* eslint-env jasmine, jquery */

describe('attachCrossDomainTrackerToInput', function () {
  var linker
  var GOVUK = window.GOVUK || {}
  var form = $('<form method="POST" action="/somewhere" class="account-signup" data-module="attach-cross-domain-tracker-to-input">' +
                 '<input type="hidden" name="key" value="value" />' +
                 '<button type="submit">Create a GOV.UK account</button>' +
               '</form>')

  var crossDomainTracker = new GOVUK.Modules.AttachCrossDomainTrackerToInput()

  beforeEach(function () {

    window.ga = {
      getAll: function () {}
    }

    window.gaplugins = {
      Linker: function () {}
    }

    linker = {
      decorate: function () {}
    }

    spyOn(window.gaplugins, 'Linker').and.returnValue(linker)
    spyOn(linker, 'decorate').and.returnValue('/somewhere?_ga=abc123')
  })

  afterEach(function () {
    form.remove()
  })

  it('leaves the form action if unchanged there are no trackers in ga', function () {
    spyOn(window.ga, 'getAll').and.returnValue([])
    console.log("THIS SHOULD BE EMPTY", window.ga.getAll())
    crossDomainTracker.start(form)
    expect(form.attr('action')).toEqual('/somewhere')
  })

  it('modifies the form action to append ids from ga to the destination url', function () {
    trackers = [{ga_mock: "abc123"}]
    spyOn(window.ga, 'getAll').and.returnValue(trackers)
    crossDomainTracker.start(form)
    expect(form.attr('action')).toEqual('/somewhere?_ga=abc123')
  })
})
