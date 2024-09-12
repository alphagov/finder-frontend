describe('Filter panel module', () => {
  'use strict'

  let filterPanel, fixture

  const loadFilterPanelComponent = (markup) => {
    fixture = document.createElement('div')
    document.body.appendChild(fixture)
    fixture.innerHTML = markup
    filterPanel = new GOVUK.Modules.FilterPanel(fixture.querySelector('.app-c-filter-panel'))
  }

  const html = `<div data-module="filter-panel" class="app-c-filter-panel">
    <div class="app-c-filter-panel__header">
      <button class="app-c-filter-panel__button govuk-link" aria-controls="filter-panel" id="filters-button">
        <span class="app-c-filter-panel__button-icon"></span>
        Filter and sort
      </button>
      <h2 class="gem-c-heading govuk-heading-s">
        123,456 results
      </h2>
    </div>
    <div class="app-c-filter-panel__content" id="filter-panel" role="region" aria-labelledby="filters-button">
      <p class="govuk-body">
        I can contain arbitrary content, usually a set of filters and sort options.
      </p>
    </div>
  </div>`

  beforeEach(() => {
    loadFilterPanelComponent(html)
    filterPanel.init()
  })

  afterEach(() => {
    fixture.remove()
  })

  it('is labelled by the open/close button', () => {
    expect(filterPanel.$content.getAttribute('aria-labelledby')).toBe(filterPanel.$button.id)
  })

  it('closes the panel on initialisation', () => {
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('false')
    expect(filterPanel.$content.hasAttribute('hidden')).toBe(true)
  })

  it('does not close the panel on initialisation if the open attribute is set', () => {
    loadFilterPanelComponent(html)
    filterPanel.$module.setAttribute('open', 'open')
    filterPanel.init()

    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('true')
    expect(filterPanel.$content.hasAttribute('hidden')).toBe(false)
  })

  it('sets the correct attributes when panel is opened', () => {
    filterPanel.$button.click()
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('true')
    expect(filterPanel.$content.hasAttribute('hidden')).toBe(false)
  })

  it('sets the correct attributes when panel is closed', () => {
    filterPanel.$button.click()
    filterPanel.$button.click()
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('false')
    expect(filterPanel.$content.hasAttribute('hidden')).toBe(true)
    expect(document.activeElement).not.toBe(filterPanel.$button)
  })

  it('prevents any default behaviour of the panel open/close button', () => {
    filterPanel.$button.addEventListener('click', (event) => {
      expect(event.defaultPrevented).toBe(true)
    })
    filterPanel.$button.click()
  })
})
