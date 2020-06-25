/* eslint-env browser, jquery */
/* global GOVUK */

//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/all_components
//
//= require support
//
//= require live_search
//= require search-analytics
//= require taxonomy-select
//= require_tree ./modules
//= require_tree ./components

jQuery(function ($) {
  var $form = $('.js-live-search-form')

  var $results = $('.js-live-search-results-block')

  var $elementsRequiringJavascript = $('.js-required')

  var $atomAutodiscoveryLink = $("link[type='application/atom+xml']").eq('0')

  var $transitionSubscribeButton = document.querySelector('.js-subscribe-button-tracker')

  $elementsRequiringJavascript.show()

  if ($form.length && $results.length) {
    // eslint-disable-next-line
    new GOVUK.LiveSearch({
      $form: $form,
      $results: $results,
      $atomAutodiscoveryLink: $atomAutodiscoveryLink
    })
  }

  if ($transitionSubscribeButton) {
    var emailSignupAnalytics = new GOVUK.Modules.EmailSignupAnalytics()

    var params = {
      $button: $transitionSubscribeButton,
      'action': 'subscribe',
      'category': 'transition-email-alert'
    }

    emailSignupAnalytics.trackSubscriptions(params)
  }
})
