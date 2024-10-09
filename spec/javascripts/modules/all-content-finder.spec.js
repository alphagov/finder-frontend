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
          </div>
        </div>
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
    })
  })
})
