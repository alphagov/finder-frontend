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
        <span class="accordion-title">
          <span class="app-c-filter-panel__button-icon"></span>
          Filter and sort
        </span>
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

  it('panel is labelled by the open/close button', () => {
    expect(filterPanel.$panel.getAttribute('aria-labelledby')).toBe(filterPanel.$button.id)
  })

  it('initial state of the panel is closed', () => {
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('false')
    expect(filterPanel.$panel.hasAttribute('hidden')).toBe(true)
  })

  it('sets the correct attributes when panel is opened', () => {
    filterPanel.$button.click()
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('true')
    expect(filterPanel.$panel.hasAttribute('hidden')).toBe(false)
    expect(filterPanel.$button.classList.contains('app-c-filter-panel__button--focused')).toBe(true)
  })

  it('sets the correct attributes when panel is closed', () => {
    filterPanel.$button.click()
    filterPanel.$button.click()
    expect(filterPanel.$button.getAttribute('aria-expanded')).toBe('false')
    expect(filterPanel.$panel.hasAttribute('hidden')).toBe(true)
    expect(filterPanel.$button.classList.contains('app-c-filter-panel__button--focused')).toBe(true)
  })

  it('removes focus class when button is blurred', () => {
    filterPanel.$button.click()
    window.GOVUK.triggerEvent(filterPanel.$button, 'blur')
    expect(filterPanel.$button.classList.contains('app-c-filter-panel__button--focused')).toBe(false)
  })
})
