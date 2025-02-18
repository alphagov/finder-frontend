describe('nested-facets', function () {
  'use strict'

  var GOVUK = window.GOVUK
  var facets

  var facetsHTML = `
    <label for='parent_facet_key'>Category</label> 
    <select name='parent_facet_key' id='parent_facet_key'> 
    <option value=''>All</option> 
    <option value='parent-facet-1'>Parent Facet 1</option> 
    <option value='parent-facet-2'>Parent Facet 2</option> 
    </select>
    <label for='child_facet_key'>Subcategory</label> 
    <select name='child_facet_key' id='child_facet_key'> 
    <option value=''>All subcategories</option> 
    <option data-parent='parent-facet-1' value='parent-1-child-facet-1'>Parent 1 Child Facet 1</option> 
    <option data-parent='parent-facet-1' value='parent-1-child-facet-2'>Parent 1 Child Facet 2</option> 
    <option data-parent='parent-facet-2' value='parent-2-child-facet-1'>Parent 2 Child Facet 1</option> 
    <option data-parent='parent-facet-2' value='parent-2-child-facet-2'>Parent 2 Child Facet 2</option> 
    </select> 
`

  beforeEach(function () {
    facets = document.createElement('div')
    facets.classList.add('js-nested-facets')
    facets.setAttribute('data-attributes', JSON.stringify({
      parent_facet_id: 'parent_facet_key',
      child_facet_id: 'child_facet_key'
    }))
    facets.innerHTML = facetsHTML
    document.body.appendChild(facets)

    new GOVUK.Modules.NestedFacets(facets).init()
  })

  afterEach(function () {
    document.body.removeChild(facets)
  })

  it('renders corresponding child facets when selecting the parent', function () {
    const parentSelect = document.getElementById('parent_facet_key')
    parentSelect.value = 'parent-facet-1'
    const event = new Event('change', { bubbles: true })
    parentSelect.dispatchEvent(event)

    const childSelect = facets.querySelector('select[name=child_facet_key]')
    const childrenValues = Array.from(childSelect.options).map((option) => option.value)
    const childrenLabels = Array.from(childSelect.options).map((option) => option.text)
    expect(childrenValues).toEqual(['', 'parent-1-child-facet-1', 'parent-1-child-facet-2'])
    expect(childrenLabels).toEqual(['All subcategories', 'Parent 1 Child Facet 1', 'Parent 1 Child Facet 2'])
  })

  it('defaults to "All" subcategories ', () => {
    const parentSelect = document.getElementById('parent_facet_key')
    parentSelect.value = 'parent-facet-2'
    const event = new Event('change', { bubbles: true })
    parentSelect.dispatchEvent(event)

    const childSelect = facets.querySelector('select[name=child_facet_key]')
    expect(childSelect.value).toEqual('')
    expect(childSelect.options[childSelect.selectedIndex].text).toEqual('All subcategories')
  })

  it('disables the child select when parent selection is "All"', () => {
    const parentSelect = document.getElementById('parent_facet_key')
    parentSelect.value = ''
    const event = new Event('change', { bubbles: true })
    parentSelect.dispatchEvent(event)

    const childSelect = facets.querySelector('select[name=child_facet_key]')
    const childrenLabels = Array.from(childSelect.options).map((option) => option.text)
    expect(childrenLabels).toEqual(['All subcategories'])
    expect(childSelect.disabled).toBe(true)
  })
})
