/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Mobile filters modal', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
    '<form method="get" class="js-live-search-form">' +
    '<button class="app-c-button-as-link app-mobile-filters-link js-show-mobile-filters"' +
      'data-toggle="mobile-filters-modal" data-target="facet-wrapper">Filter' +
    '</button>' +
    '<div id="facet-wrapper" data-module="mobile-filters-modal" class="facets">' +
      '<div class="facets__box">' +
        '<div class="facets__header">' +
          '<h1 class="gem-c-title__text">Filter</h1>' +
          '<button class="app-c-button-as-link facets__return-link js-close-filters" type="button">' +
            'Return to results' +
          '</button>' +
        '</div>' +
        '<div class="facets__content">' +
          '<select>' +
            '<option value>All options</option>' +
            '<option value="1" selected="selected">Selected</option>' +
          '</select>' +
          '<input type="checkbox" id="checkbox-one" name="checkbox-one" checked>' +
          '<label for="checkbox-one">Chekbox 2</label>' +
          '<input type="checkbox" id="checkbox-two" name="checkbox-two">' +
          '<label for="checkbox-two">Checkbox 2</label>' +
          '<input name="input-one" type="text" value="">' +
          '<input name="input-two" type="text" value="text input value">' +
          '<button class="app-c-button-as-link facets__clear-link js-clear-selected-filters" type="button">' +
            'Clear all filters' +
          '</button>' +
        '</div>' +
        '<div class="facets__footer">' +
          '<button class="gem-c-button govuk-button js-close-filters" type="button">' +
            'Show <span class="js-result-count">9<span>' +
          '</button>' +
        '</div>' +
      '</div>' +
    '</div>' +
    '</form>'

    document.body.appendChild(container)
    var element = $('[data-module="mobile-filters-modal"]')
    new GOVUK.Modules.MobileFiltersModal().start(element)
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('open button', function () {
    beforeEach(function () {
      document.querySelector('.js-show-mobile-filters').click()
    })

    afterEach(function () {
      document.querySelector('.js-close-filters').click()
    })

    it('should show the modal', function () {
      var modal = document.querySelector('.facets')
      expect($(modal).is(':visible')).toBe(true)
    })
  })

  describe('close button', function () {
    it('should hide the modal', function () {
      document.querySelector('.js-show-mobile-filters').click()
      document.querySelector('.js-close-filters').click()

      var modal = document.querySelector('.facets')
      document.querySelector('.js-close-filters').click()
      expect($(modal).is(':visible')).toBe(false)
    })
  })

  describe('open', function () {
    beforeEach(function () {
      var modal = document.querySelector('.facets')
      modal.open()
    })

    afterEach(function () {
      var modal = document.querySelector('.facets')
      modal.close()
    })

    it('should show the modal', function () {
      var modal = document.querySelector('.facets')
      expect($(modal).is(':visible')).toBe(true)
    })

    it('should focus the modal', function () {
      var modalFocused = document.querySelector('.facets__box')
      expect(modalFocused).toBeTruthy()
    })
  })

  describe('close', function () {
    it('should hide the modal', function () {
      var modal = document.querySelector('.facets')
      modal.open()
      modal.close()
      expect($(modal).is(':visible')).toBe(false)
    })
  })

  describe('clear filters', function () {
    it('should reset checkboxes, clear text input and <select> values', function () {
      var modal = document.querySelector('.facets')
      modal.clearFilters()
      expect($(modal).find('input:checked').length).toBe(0)
      // number of text inputs with value should now be 0
      expect($(modal).find('input[type="text"]')
        .filter(function () { return $(this).val() }).length).toBe(0)
      expect($(modal).find('select').val()).toBe('')
    })
  })
})
