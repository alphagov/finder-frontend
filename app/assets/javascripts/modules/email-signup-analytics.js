/* eslint-env browser */
/* global GOVUK */

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function EmailSignupAnalytics () {}

  EmailSignupAnalytics.prototype.trackSubscriptions = function (params) {
    var $button = params.$button

    var category = params.category

    var action = params.action

    $button.addEventListener('click', function () {
      GOVUK.analytics.trackEvent('Subscribe button clicked', action, { 'category': category })
    })
  }

  Modules.EmailSignupAnalytics = EmailSignupAnalytics
})(window.GOVUK.Modules)
