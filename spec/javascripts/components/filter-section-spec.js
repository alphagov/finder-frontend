describe('Filter section module', () => {
  'use strict'

  let filterSection, fixture

  const loadFilterSectionComponent = (markup) => {
    fixture = document.createElement('div')
    document.body.appendChild(fixture)
    fixture.innerHTML = markup
    filterSection = new GOVUK.Modules.FilterSection(fixture.querySelector('.app-c-filter-section'))
  }

  const html = `<details data-module="filter-section" class="app-c-filter-section">
      <summary class="app-c-filter-section__summary" data-ga4-event="{}">
        filter section
      </summary>
      <div>content</div>
    </details>`

  beforeEach(() => {
    loadFilterSectionComponent(html)
    filterSection.init()
  })

  afterEach(() => {
    fixture.remove()
  })

  it('sets correct ga4 tracking data when panel is opened and closed', () => {
    filterSection.$summary.click()
    expect(JSON.parse(filterSection.$summary.getAttribute('data-ga4-event')).action).toBe('opened')

    filterSection.$summary.click()
    expect(JSON.parse(filterSection.$summary.getAttribute('data-ga4-event')).action).toBe('closed')
  })
})
