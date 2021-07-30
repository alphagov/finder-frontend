window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function MobileFiltersModal ($module) {
    this.$module = $module
    this.$facetsBox = this.$module.querySelector('.facets__box')
    this.$closeTriggers = this.$module.querySelectorAll('.js-close-filters')
    this.$showResultsButton = this.$module.querySelector('.js-show-results')
    this.$clearFiltersTrigger = this.$module.querySelector('.js-clear-selected-filters')
    this.$body = document.querySelector('body')

    this.$module.open = this.handleOpen.bind(this)
    this.$module.close = this.handleClose.bind(this)
    this.$module.clearFilters = this.handleClearFilters.bind(this)
    this.$module.ModalFocus = this.handleModalFocus.bind(this)
    this.$module.boundKeyDown = this.handleKeyDown.bind(this)
  }

  MobileFiltersModal.prototype.init = function () {
    var $triggerElement = document.querySelector(
      '[data-toggle="mobile-filters-modal"][data-target="' + this.$module.id + '"]'
    )
    if ($triggerElement) {
      $triggerElement.addEventListener('click', this.$module.open)
    }

    if (this.$closeTriggers) {
      for (var t = 0; t < this.$closeTriggers.length; t++) {
        this.$closeTriggers[t].addEventListener('click', this.$module.close)
      }
    }

    if (this.$clearFiltersTrigger) {
      this.$clearFiltersTrigger.addEventListener('click', this.$module.clearFilters)
    }
  }

  MobileFiltersModal.prototype.handleOpen = function (event) {
    if (event) {
      event.preventDefault()
    }
    // when our support browser matrix is above iOS 13
    // we can use overflow: hidden on the <body> and remove position: fixed
    this.$body.style.top = '-' + window.scrollY + 'px'
    this.$body.style.position = 'fixed'
    this.$focusedElementBeforeOpen = document.activeElement
    this.$module.classList.add('facets--visible')
    this.$facetsBox.setAttribute('aria-modal', true)
    this.$facetsBox.setAttribute('tabindex', 0)
    this.$facetsBox.focus()

    document.addEventListener('keydown', this.$module.boundKeyDown, true)
  }

  MobileFiltersModal.prototype.handleClose = function (event) {
    if (event) {
      event.preventDefault()
    }

    var offsetTop = this.$body.style.top
    this.$body.style.position = ''
    this.$body.style.top = ''
    window.scrollTo(0, parseInt(offsetTop || '0') * -1)
    this.$module.classList.remove('facets--visible')
    this.$facetsBox.removeAttribute('aria-modal')
    this.$facetsBox.removeAttribute('tabindex')
    this.$focusedElementBeforeOpen.focus()

    document.removeEventListener('keydown', this.$module.boundKeyDown, true)
  }

  MobileFiltersModal.prototype.handleModalFocus = function () {
    this.$facetsBox.focus()
  }

  // while open, prevent tabbing to outside the dialogue
  // and listen for ESC key to close the dialogue
  MobileFiltersModal.prototype.handleKeyDown = function (event) {
    var KEY_TAB = 9
    var KEY_ESC = 27

    switch (event.keyCode) {
      case KEY_TAB:
        if (event.shiftKey) {
          if (document.activeElement === this.$facetsBox) {
            event.preventDefault()
            this.$showResultsButton.focus()
          }
        } else {
          if (document.activeElement === this.$showResultsButton) {
            event.preventDefault()
            this.$facetsBox.focus()
          }
        }
        break
      case KEY_ESC:
        this.$module.close()
        break
      default:
        break
    }
  }

  MobileFiltersModal.prototype.handleClearFilters = function (event) {
    if (event) {
      event.preventDefault()
    }
    // reset all selects, uncheck checkboxes, clear text input values
    // and remove the selected count on each facet
    var $elements = this.$module.querySelectorAll('input, select, .js-selected-counter')
    var $form = document.querySelector('.js-live-search-form')
    var customEvent = document.createEvent('HTMLEvents')
    customEvent.initEvent('customFormChange', true, false)
    for (var i = 0; i < $elements.length; i++) {
      var $el = $elements[i]
      var tagName = $el.tagName
      switch (tagName) {
        case 'INPUT':
          if ($el.type === 'checkbox' && $el.checked === true) {
            $el.checked = false
          } else if ($el.type === 'text' && $el.value !== '') {
            $el.value = ''
          }
          break
        case 'SELECT':
          $el.value = ''
          break
        case 'DIV':
          $el.parentNode.removeChild($el)
          break
        default:
          break
      }
    }
    // fire a single custom change event on the form once all filters have been cleared
    // so that we only fetch new search-api data once
    $form.dispatchEvent(customEvent)
  }

  Modules.MobileFiltersModal = MobileFiltersModal
})(window.GOVUK.Modules)
