window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function NestedFacets (module) {
    this.module = module
    this.options = this.instantiateOptions()
  }

  NestedFacets.prototype.init = function () {
    if (this.module) {
      this.update()
      this.module.addEventListener('change', () => {
        this.update()
      })
    }
  }

  NestedFacets.prototype.update = function updateFacets () {
    this.setChildFacetSelectDisabledState()
    this.resetChildFacetValue()
    this.populateSubFacets()
  }

  NestedFacets.prototype.$parentFacets = function $parentFacets () {
    const parentFacetId = JSON.parse(this.module.dataset.attributes).parent_facet_id
    return this.module.querySelector('#' + parentFacetId)
  }

  NestedFacets.prototype.$childFacet = function $childFacet () {
    const childFacetId = JSON.parse(this.module.dataset.attributes).child_facet_id
    return this.module.querySelector('#' + childFacetId)
  }

  NestedFacets.prototype.setChildFacetSelectDisabledState =
    function setChildFacetSelectDisabledState () {
      var selectedParentFacet = !!this.$parentFacets().value
      if (!selectedParentFacet) {
        this.$childFacet().setAttribute('disabled', true)
      } else {
        this.$childFacet().removeAttribute('disabled')
      }
    }

  NestedFacets.prototype.populateSubFacets = function populateSubFacets () {
    var facet = this.options[this.$parentFacets().value]
    var childFacet = this.$childFacet()
    var options = childFacet.querySelectorAll('option')

    for (var o = 0; o < options.length; o++) {
      if (options[o].value) {
        options[o].parentNode.removeChild(options[o])
      }
    }
    if (facet) {
      for (var i = 0; i < facet.length; i++) {
        childFacet.appendChild(facet[i])
      }
    }
  }

  NestedFacets.prototype.instantiateOptions = function instantiateOptions () {
    var options = {}
    var optionElements = this.$childFacet().querySelectorAll('option')

    for (var o = 0; o < optionElements.length; o++) {
      var parent = optionElements[o].getAttribute('data-parent')

      options[parent] = options[parent] || []
      options[parent].push(optionElements[o])
    }
    return options
  }

  NestedFacets.prototype.resetChildFacetValue =
    function resetChildFacetValue () {
      var selected =
        this.$childFacet().options[this.$childFacet().selectedIndex]
      var parentFacet = this.$parentFacets().value
      var isOrphanedChild =
        selected && selected.getAttribute('data-parent') !== parentFacet

      if (isOrphanedChild) {
        this.$childFacet().value = ''
      }
    }

  Modules.NestedFacets = NestedFacets
})(window.GOVUK.Modules)
