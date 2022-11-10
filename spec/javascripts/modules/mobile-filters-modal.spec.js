describe('Mobile filters modal', function () {
  'use strict'

  var container

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
    '<form method="get" class="js-live-search-form">' +
    '<button class="app-c-button-as-link app-mobile-filters-link js-toggle-mobile-filters"' +
      'data-toggle="mobile-filters-modal" data-target="facet-wrapper">Filter' +
    '</button>' +
    '<div id="facet-wrapper" data-module="mobile-filters-modal" class="facets">' +
      '<div class="facets__box">' +
        '<div class="facets__header">' +
          '<h2 class="gem-c-title__text">Filter</h2>' +
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
          '<a class="gem-c-button govuk-button" role="button" data-module="govuk-button govuk-skip-link" draggable="false" href="#js-results" data-govuk-button-module-started="true" data-govuk-skip-link-module-started="true">' +
            'Go to search results' +
          '</a>' +
        '</div>' +
      '</div>' +
    '</div>' +
    '</form>'

    document.body.appendChild(container)

    container.addEventListener('submit', function (e) {
      e.preventDefault()
    })

    var element = $('[data-module="mobile-filters-modal"]')[0]
    new GOVUK.Modules.MobileFiltersModal(element).init()
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('open button', function () {
    beforeEach(function () {
      document.querySelector('.js-toggle-mobile-filters').click()
    })

    afterEach(function () {
      document.querySelector('.js-toggle-mobile-filters').click()
    })

    it('should show the modal', function () {
      var modal = document.querySelector('.facets')
      expect($(modal).hasClass('facets--visible')).toBe(true)
    })

    it('should hide the modal', function () {
      var modal = document.querySelector('.facets')
      document.querySelector('.js-toggle-mobile-filters').click()
      expect($(modal).hasClass('facets--visible')).toBe(false)
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
      expect($(modal).hasClass('facets--visible')).toBe(true)
    })
  })

  describe('close', function () {
    it('should hide the modal', function () {
      var modal = document.querySelector('.facets')
      modal.open()
      modal.close()
      expect($(modal).hasClass('facets--visible')).toBe(false)
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

  describe('accessibility', function () {
    it('should add aria-expanded="false" on load to the Filter button', function () {
      var button = document.querySelector('.js-toggle-mobile-filters')
      expect(button.getAttribute('aria-expanded')).toEqual('false')
    })

    it('should set aria-expanded to true when clicking the Filter button', function () {
      var button = document.querySelector('.js-toggle-mobile-filters')
      button.click()
      expect(button.getAttribute('aria-expanded')).toEqual('true')
    })

    it('should add aria-controls on load to the Filter button', function () {
      var button = document.querySelector('.js-toggle-mobile-filters')
      expect(button.getAttribute('aria-controls')).toEqual('facet-wrapper')
      expect(document.querySelector('#facet-wrapper')).not.toEqual(null)
    })
  })
})
