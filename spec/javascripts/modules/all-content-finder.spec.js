describe('AllContentFinder module', () => {
  'use strict'

  let allContentFinder, fixture

  const html = `<div class="app-all-content-finder" data-module="all-content-finder">
    <form method="get" action="/search/all" id="all-content-finder-form" class="js-all-content-finder-form">
      <div class="govuk-grid-row">
        <div class="govuk-grid-column-two-thirds-from-desktop">
          <div id="keywords" role="search" aria-label="Sitewide">
            <div class="gem-c-search">
              <input enterkeyhint="search" class="gem-c-search__input js-class-toggle" id="finder-keyword-search" name="keywords" type="search" value="" />
              <button class="gem-c-search__submit" type="submit">Search</button>
            </div>
          </div>
          <div data-ga4-change-category="FooCategory">
            <input name="foo" id="foo" type="text" value="bar" />
            <input name="bar" id="bar" type="text" value="" />
          </div>
        </div>
      </div>
      <div class="govuk-form-group govuk-!-margin-bottom-2">
        <fieldset class="govuk-fieldset">
          <legend class="govuk-fieldset__legend govuk-fieldset__legend--m govuk-visually-hidden">
            <span class="govuk-fieldset__heading">Sort order</span>
          </legend>
          <div class="govuk-radios govuk-radios--small">
            <div class="gem-c-radio govuk-radios__item">
              <input type="radio" name="order" id="radio-6215576f-0" value="relevance" class="govuk-radios__input">
              <label for="radio-6215576f-0" class="gem-c-label govuk-label govuk-radios__label">Relevance</label>
            </div>
            <div class="gem-c-radio govuk-radios__item">
              <input type="radio" name="order" id="radio-6215576f-0" value="most-viewed" class="govuk-radios__input">
              <label for="radio-6215576f-0" class="gem-c-label govuk-label govuk-radios__label">Most viewed</label>
            </div>
            <div class="gem-c-radio govuk-radios__item">
              <input type="radio" name="order" id="radio-6215576f-1" value="updated-newest" class="govuk-radios__input">
              <label for="radio-6215576f-1" class="gem-c-label govuk-label govuk-radios__label">Updated (newest)</label>
            </div>
            <div class="gem-c-radio govuk-radios__item">
              <input type="radio" name="order" id="radio-6215576f-2" value="updated-oldest" class="govuk-radios__input">
              <label for="radio-6215576f-2" class="gem-c-label govuk-label govuk-radios__label">Updated (oldest)</label>
            </div>
          </div>
        </fieldset>
      </div>
      <div class="js-all-content-finder-taxonomy-select">
        <div class="govuk-form-group gem-c-select">
          <label class="govuk-label" for="level_one_taxon">Filter by topic</label>
          <select class="govuk-select" id="level_one_taxon" name="level_one_taxon">
            <option value="">All topics</option>
            <option value="foo">Foo</option>
          </select>
        </div>
        <div class="js-required govuk-form-group gem-c-select">
          <label class="govuk-label" for="level_two_taxon">Filter by sub-topic</label>
          <select class="govuk-select" id="level_two_taxon" name="level_two_taxon" disabled="disabled">
            <option data-topic-parent="" value="">All sub-topics</option>
            <option data-topic-parent="foo" value="bar">Bar</option>
          </select>
        </div>
      </div>
    </form>
  </div>`

  beforeEach(() => {
    fixture = document.createElement('div')
    document.body.appendChild(fixture)
    fixture.innerHTML = html
    allContentFinder = new GOVUK.Modules.AllContentFinder(fixture.querySelector('.app-all-content-finder'))
  })

  afterEach(() => {
    fixture.remove()
  })

  describe('form submission', () => {
    let form, mockSubmitHandler

    beforeEach(() => {
      allContentFinder.init()
      form = fixture.querySelector('.js-all-content-finder-form')
      mockSubmitHandler = jasmine.createSpy('submit')

      form.addEventListener('submit', (e) => {
        e.preventDefault()
        mockSubmitHandler(new FormData(form))
      })
    })

    it('submits the form with all the expected fields, removing empty ones', () => {
      form.dispatchEvent(new Event('submit'))

      expect(mockSubmitHandler).toHaveBeenCalled()
      const submittedData = mockSubmitHandler.calls.mostRecent().args[0]

      expect(submittedData.has('foo')).toBe(true)
      expect(submittedData.has('bar')).toBe(false)
      expect(submittedData.has('keywords')).toBe(false)
    })

    it('removes relevance sort order from the form data', () => {
      form.querySelector('input[value="relevance"]').checked = true
      form.dispatchEvent(new Event('submit'))

      expect(mockSubmitHandler).toHaveBeenCalled()
      const submittedData = mockSubmitHandler.calls.mostRecent().args[0]

      expect(submittedData.has('order')).toBe(false)
    })

    it('removes most-viewed sort order from the form data', () => {
      form.querySelector('input[value="most-viewed"]').checked = true
      form.dispatchEvent(new Event('submit'))

      expect(mockSubmitHandler).toHaveBeenCalled()
      const submittedData = mockSubmitHandler.calls.mostRecent().args[0]

      expect(submittedData.has('order')).toBe(false)
    })

    it('does not remove non-default sort order from the form data', () => {
      form.querySelector('input[value="updated-newest"]').checked = true
      form.dispatchEvent(new Event('submit'))

      expect(mockSubmitHandler).toHaveBeenCalled()
      const submittedData = mockSubmitHandler.calls.mostRecent().args[0]

      expect(submittedData.has('order')).toBe(true)
      expect(submittedData.get('order')).toBe('updated-newest')
    })
  })

  describe('taxonomy select', () => {
    let updateSpy
    let $taxonomySelect

    beforeEach(() => {
      updateSpy = jasmine.createSpy('update')

      spyOn(GOVUK, 'TaxonomySelect').and.callFake(function (_options) {
        this.update = updateSpy
      })

      allContentFinder.init()

      $taxonomySelect = fixture.querySelector('.js-all-content-finder-taxonomy-select')
    })

    it('initialises the taxonomy select on init and calls update', () => {
      expect(GOVUK.TaxonomySelect).toHaveBeenCalledWith({ $el: $taxonomySelect })
      expect(updateSpy).toHaveBeenCalledTimes(1)
    })

    it('calls update on the taxonomy select when a change occurs', () => {
      const event = new Event('change')
      $taxonomySelect.dispatchEvent(event)

      expect(updateSpy).toHaveBeenCalledTimes(2) // Twice including the initial call on init()
    })
  })

  describe('analytics tracking', () => {
    beforeEach(() => {
      spyOn(GOVUK.analyticsGa4.Ga4FinderTracker, 'trackChangeEvent')
      spyOn(GOVUK.analyticsGa4.Ga4EcommerceTracker, 'init')
      spyOn(GOVUK.analyticsGa4.core, 'sendData')
    })

    describe('when usage tracking is declined', () => {
      beforeEach(() => {
        GOVUK.setConsentCookie({ usage: false })
        allContentFinder.init()
      })

      it('does not fire analytics tracking on form element changes', () => {
        const event = new Event('change', { bubbles: true })
        fixture.querySelector('#foo').dispatchEvent(event)
        expect(GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent).not.toHaveBeenCalled()
      })

      it('does not fire a `search` event on form submit if the keyword has not changed', () => {
        const form = fixture.querySelector('.js-all-content-finder-form')
        form.dispatchEvent(new Event('submit', { bubbles: true }))

        expect(GOVUK.analyticsGa4.core.sendData).not.toHaveBeenCalled()
      })

      it('does not fire a `search` event on form submit even if the keyword has changed', () => {
        const form = fixture.querySelector('.js-all-content-finder-form')
        form.querySelector('input[type="search"]').value = 'new keyword'
        form.dispatchEvent(new Event('submit', { bubbles: true }))

        expect(GOVUK.analyticsGa4.core.sendData).not.toHaveBeenCalled()
      })

      it('does not set up ecommerce tracking', () => {
        expect(GOVUK.analyticsGa4.Ga4EcommerceTracker.init).not.toHaveBeenCalled()
      })
    })

    describe('when usage tracking is accepted', () => {
      beforeEach(() => {
        GOVUK.setConsentCookie({ usage: true })
        allContentFinder.init()
      })

      it('fires analytics tracking on form element changes through the GA4 finder tracker', () => {
        const event = new Event('change', { bubbles: true })
        const input = fixture.querySelector('#foo')
        input.dispatchEvent(event)

        expect(GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent).toHaveBeenCalledWith(input, 'FooCategory')
      })

      it('does not fire a `search` event on form submit if the keyword has not changed', () => {
        const form = fixture.querySelector('.js-all-content-finder-form')
        form.dispatchEvent(new Event('submit', { bubbles: true }))

        expect(GOVUK.analyticsGa4.core.sendData).not.toHaveBeenCalled()
      })

      it('fires a `search` event on form submit if the keyword has changed', () => {
        const form = fixture.querySelector('.js-all-content-finder-form')
        form.querySelector('input[type="search"]').value = 'new keyword'
        form.dispatchEvent(new Event('submit', { bubbles: true }))

        expect(GOVUK.analyticsGa4.core.sendData).toHaveBeenCalledWith(jasmine.objectContaining({
          event: 'event_data',
          event_data: jasmine.objectContaining({
            event_name: 'search',
            type: 'finder',
            text: 'new keyword',
            action: 'search',
            section: 'Search'
          })
        }))
      })

      it('sets up ecommerce tracking', () => {
        expect(GOVUK.analyticsGa4.Ga4EcommerceTracker.init).toHaveBeenCalled()
      })
    })

    describe('when usage tracking is accepted after component has already initialised', () => {
      beforeEach(() => {
        GOVUK.setConsentCookie({ usage: false })
        allContentFinder.init()
      })

      it('fires analytics tracking on form element changes through the GA4 finder tracker', () => {
        window.dispatchEvent(new Event('cookie-consent'))

        const event = new Event('change', { bubbles: true })
        const input = fixture.querySelector('#foo')
        input.dispatchEvent(event)

        expect(GOVUK.analyticsGa4.Ga4FinderTracker.trackChangeEvent).toHaveBeenCalledWith(input, 'FooCategory')
      })

      it('sets up ecommerce tracking', () => {
        window.dispatchEvent(new Event('cookie-consent'))

        expect(GOVUK.analyticsGa4.Ga4EcommerceTracker.init).toHaveBeenCalled()
      })
    })
  })
})
