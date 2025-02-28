window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function NestedFacets (module) {
    this.module = module
    this.mainFacet = document.querySelector('#' + this.module.getAttribute('data-main-facet-id'))
    this.subFacet = document.querySelector('#' + this.module.getAttribute('data-sub-facet-id'))
    this.options = this.instantiateOptions()
  }

  NestedFacets.prototype.init = function () {
    this.updateFacets()
    this.module.addEventListener('change', () => {
      this.updateFacets()
    })
  }

  NestedFacets.prototype.updateFacets = function () {
    this.setSubFacetSelectDisabledState()
    this.resetSubFacetValue()
    this.populateSubFacets()
  }

  NestedFacets.prototype.setSubFacetSelectDisabledState = function () {
    const mainFacetSelected = !!this.mainFacet.value
    if (mainFacetSelected) {
      this.subFacet.removeAttribute('disabled')
    } else {
      this.subFacet.setAttribute('disabled', true)
    }
  }

  NestedFacets.prototype.populateSubFacets = function () {
    const subFacetOptionsForSelectedMain = this.options[this.mainFacet.value]
    const subFacet = this.subFacet
    const subFacetOptions = subFacet.querySelectorAll('option')

    for (let o = 0; o < subFacetOptions.length; o++) {
      if (subFacetOptions[o].value) {
        subFacetOptions[o].parentNode.removeChild(subFacetOptions[o])
      }
    }
    if (subFacetOptionsForSelectedMain) {
      for (let i = 0; i < subFacetOptionsForSelectedMain.length; i++) {
        subFacet.appendChild(subFacetOptionsForSelectedMain[i])
      }
    }
  }

  NestedFacets.prototype.instantiateOptions = function () {
    const options = {}
    const optionElements = this.subFacet.querySelectorAll('option')

    for (let o = 0; o < optionElements.length; o++) {
      const mainFacetValue = optionElements[o].getAttribute('data-main-facet-value')

      const mainFacetLabelPrefix = optionElements[o].getAttribute('data-main-facet-label') + ' - '
      optionElements[o].text = optionElements[o].text.replace(mainFacetLabelPrefix, '')

      options[mainFacetValue] = options[mainFacetValue] || []
      options[mainFacetValue].push(optionElements[o])
    }
    return options
  }

  NestedFacets.prototype.resetSubFacetValue = function () {
    const selected = this.subFacet.options[this.subFacet.selectedIndex]
    const mainFacetValue = this.mainFacet.value
    const isOrphanedChild = selected && selected.getAttribute('data-main-facet-value') !== mainFacetValue

    if (isOrphanedChild) {
      this.subFacet.value = ''
    }
  }

  Modules.NestedFacets = NestedFacets
})(window.GOVUK.Modules)
