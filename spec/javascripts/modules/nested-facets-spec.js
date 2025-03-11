describe('nested-facets', function () {
  'use strict'

  const GOVUK = window.GOVUK
  let facetsWrapper
  const facetsHTML = `
    <label for='main_facet_key'>Category</label> 
    <select name='main_facet_key' id='main_facet_key'> 
    <option value=''>All</option> 
    <option value='main-facet-1'>Main Facet 1</option> 
    <option value='main-facet-2'>Main Facet 2</option> 
    </select>
    <label for='sub_facet_key'>Subcategory</label> 
    <select name='sub_facet_key' id='sub_facet_key'> 
    <option value=''>All subcategories</option> 
    <option data-main-facet-value='main-facet-1' data-main-facet-label='Main 1' value='main-1-sub-facet-1'>Main 1 - Main 1 Sub Facet 1</option> 
    <option data-main-facet-value='main-facet-1' data-main-facet-label='Main 1' value='main-1-sub-facet-2'>Main 1 - Main 1 Sub Facet 2</option> 
    <option data-main-facet-value='main-facet-2' data-main-facet-label='Main 2' value='main-2-sub-facet-1'>Main 1 - Main 2 Sub Facet 1</option> 
    <option data-main-facet-value='main-facet-2' data-main-facet-label='Main 2' value='main-2-sub-facet-2'>Main 2 - Main 2 Sub Facet 2</option> 
    </select> 
   `

  beforeEach(function () {
    facetsWrapper = document.createElement('div')
    facetsWrapper.setAttribute('data-main-facet-id', 'main_facet_key')
    facetsWrapper.setAttribute('data-sub-facet-id', 'sub_facet_key')
    facetsWrapper.innerHTML = facetsHTML

    document.body.appendChild(facetsWrapper)
    new GOVUK.Modules.NestedFacets(facetsWrapper).init()
  })

  afterEach(function () {
    document.body.removeChild(facetsWrapper)
  })

  it('renders corresponding sub facets when selecting the main facet', function () {
    const mainSelect = document.getElementById('main_facet_key')
    mainSelect.value = 'main-facet-1'
    const event = new Event('change', { bubbles: true })
    mainSelect.dispatchEvent(event)

    const subSelect = document.querySelector('select[name=sub_facet_key]')
    const subValues = Array.from(subSelect.options).map((option) => option.value)
    const subLabels = Array.from(subSelect.options).map((option) => option.text)
    expect(subValues).toEqual(['', 'main-1-sub-facet-1', 'main-1-sub-facet-2'])
    expect(subLabels).toEqual(['All subcategories', 'Main 1 Sub Facet 1', 'Main 1 Sub Facet 2'])
  })

  it('defaults to "All" subcategories ', () => {
    const mainSelect = document.getElementById('main_facet_key')
    mainSelect.value = 'main-facet-2'
    const event = new Event('change', { bubbles: true })
    mainSelect.dispatchEvent(event)

    const subSelect = document.querySelector('select[name=sub_facet_key]')
    expect(subSelect.value).toEqual('')
    expect(subSelect.options[subSelect.selectedIndex].text).toEqual('All subcategories')
  })

  it('disables the sub facet select when main selection is "All"', () => {
    const mainSelect = document.getElementById('main_facet_key')
    mainSelect.value = ''
    const event = new Event('change', { bubbles: true })
    mainSelect.dispatchEvent(event)

    const subSelect = document.querySelector('select[name=sub_facet_key]')
    const subLabels = Array.from(subSelect.options).map((option) => option.text)
    expect(subLabels).toEqual(['All subcategories'])
    expect(subSelect.disabled).toBe(true)
  })
})
