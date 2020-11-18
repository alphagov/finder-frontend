// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//= require govuk_publishing_components/dependencies
//= require govuk_publishing_components/lib
//= require govuk_publishing_components/components/button
//= require govuk_publishing_components/components/checkboxes
//= require govuk_publishing_components/components/details
//= require govuk_publishing_components/components/feedback
//= require govuk_publishing_components/components/govspeak
//= require govuk_publishing_components/components/radio
//
//= require support
//
//= require live_search
//= require search-analytics
//= require taxonomy-select
//= require ga_cross_domain_form_tracking
//= require_tree ./modules
//= require_tree ./components

/* eslint-env jquery */

jQuery(function ($) {
  var $form = $('.js-live-search-form')

  var $results = $('.js-live-search-results-block')

  var $elementsRequiringJavascript = $('.js-required')

  var $atomAutodiscoveryLink = $("link[type='application/atom+xml']").eq('0')

  $elementsRequiringJavascript.show()

  if ($form.length && $results.length) {
    // eslint-disable-next-line
    new GOVUK.LiveSearch({
      $form: $form,
      $results: $results,
      $atomAutodiscoveryLink: $atomAutodiscoveryLink
    })
  }
})
