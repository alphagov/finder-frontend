describe('SearchAnalytics', function () {
  'use strict'

  var GOVUK = window.GOVUK || {}

  describe('when GOVUK.analytics is undefined', function () {
    beforeEach(function () {
      GOVUK.analytics = undefined
    })

    describe('trackEvent', function () {
      it('does not raise an error', function () {
        expect(GOVUK.SearchAnalytics.trackEvent).not.toThrow()
      })
    })

    describe('trackPageview', function () {
      it('does not raise an error', function () {
        expect(GOVUK.SearchAnalytics.trackPageview).not.toThrow()
      })
    })

    describe('setDimension', function () {
      it('does not raise an error', function () {
        expect(GOVUK.SearchAnalytics.setDimension).not.toThrow()
      })
    })
  })

  describe('when GOVUK.analytics is defined', function () {
    beforeEach(function () {
      GOVUK.analytics = {
        trackPageview: function () { },
        trackEvent: function () { },
        setDimension: function () {}
      }
    })

    describe('trackEvent', function () {
      it('forwards arguments to GOVUK.analytics', function () {
        spyOn(GOVUK.analytics, 'trackEvent')
        GOVUK.SearchAnalytics.trackEvent('category', 'action', {})
        expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
          'category', 'action', {})
      })
    })

    describe('trackPageview', function () {
      it('forwards arguments to GOVUK.analytics', function () {
        spyOn(GOVUK.analytics, 'trackPageview')
        GOVUK.SearchAnalytics.trackPageview('/breakfast')
        expect(GOVUK.analytics.trackPageview).toHaveBeenCalledWith('/breakfast')
      })
    })

    describe('setDimension', function () {
      it('forwards arguments to GOVUK.analytics', function () {
        spyOn(GOVUK.analytics, 'setDimension')
        GOVUK.SearchAnalytics.setDimension(83, 'something')
        expect(GOVUK.analytics.setDimension).toHaveBeenCalledWith(83, 'something')
      })
    })
  })
})
