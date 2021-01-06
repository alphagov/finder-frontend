window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function OptionSelect () {}

  /* This JavaScript provides two functional enhancements to option-select components:
    1) A count that shows how many results have been checked in the option-container
    2) Open/closing of the list of checkboxes
  */
  OptionSelect.prototype.start = function ($module) {
    this.$optionSelect = $module
    this.$options = this.$optionSelect.find("input[type='checkbox']")
    this.$optionsContainer = this.$optionSelect.find('.js-options-container')
    this.$optionList = this.$optionsContainer.children('.js-auto-height-inner')
    this.$allCheckboxes = this.$optionsContainer.find('.govuk-checkboxes__item')
    this.hasFilter = this.$optionSelect.data('filter-element') || ''
    this.checkedCheckboxes = []

    if (this.hasFilter.length) {
      var filterEl = document.createElement('div')
      filterEl.innerHTML = this.hasFilter

      $('<div class="app-c-option-select__filter"/>')
        .html(filterEl.childNodes[0].nodeValue)
        .insertBefore(this.$optionsContainer)

      this.$filter = this.$optionSelect.find('input[name="option-select-filter"]')
      this.$filterCount = $('#' + this.$filter.attr('aria-describedby'))
      this.filterTextSingle = ' ' + this.$filterCount.data('single')
      this.filterTextMultiple = ' ' + this.$filterCount.data('multiple')
      this.filterTextSelected = ' ' + this.$filterCount.data('selected')
      this.checkboxLabels = []
      this.filterTimeout = 0
      var that = this

      this.getAllCheckedCheckboxes()
      this.$allCheckboxes.each(function () {
        that.checkboxLabels.push(that.cleanString($(this).text()))
      })

      this.$filter.on('keyup', function (e) {
        e.stopPropagation()
        var ENTER_KEY = 13

        if (e.keyCode !== ENTER_KEY) {
          clearTimeout(that.filterTimeout)
          that.filterTimeout = setTimeout(
            function () { this.doFilter(this) }.bind(that),
            300
          )
        } else {
          e.preventDefault() // prevents finder forms from being submitted when user presses ENTER
        }
      })
    }

    // Attach listener to update checked count
    this.$optionSelect.on('change', "input[type='checkbox']", this.updateCheckedCount.bind(this))

    // Replace div.container-head with a button
    this.replaceHeadingSpanWithButton()

    // Add js-collapsible class to parent for CSS
    this.$optionSelect.addClass('js-collapsible')

    // Add open/close listeners
    this.$optionSelect.find('.js-container-button').on('click', this.toggleOptionSelect.bind(this))

    if (this.$optionSelect.data('closed-on-load') === true) {
      this.close()
    } else {
      this.setupHeight()
    }

    var checkedString = this.checkedString()
    if (checkedString) {
      this.attachCheckedCounter(checkedString)
    }
  }

  OptionSelect.prototype.cleanString = function cleanString (text) {
    text = text.replace(/&/g, 'and')
    text = text.replace(/[’',:–-]/g, '') // remove punctuation characters
    text = text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') // escape special characters
    return text.trim().replace(/\s\s+/g, ' ').toLowerCase() // replace multiple spaces with one
  }

  OptionSelect.prototype.getAllCheckedCheckboxes = function getAllCheckedCheckboxes () {
    this.checkedCheckboxes = []
    var that = this

    this.$allCheckboxes.each(function (i) {
      if ($(this).find('input[type=checkbox]').is(':checked')) {
        that.checkedCheckboxes.push(i)
      }
    })
  }

  OptionSelect.prototype.doFilter = function doFilter (obj) {
    var filterBy = obj.cleanString(obj.$filter.val())
    var showCheckboxes = obj.checkedCheckboxes.slice()

    for (var i = 0; i < obj.$allCheckboxes.length; i++) {
      if (showCheckboxes.indexOf(i) === -1 && obj.checkboxLabels[i].search(filterBy) !== -1) {
        showCheckboxes.push(i)
      }
    }

    obj.$allCheckboxes.hide()
    for (var j = 0; j < showCheckboxes.length; j++) {
      obj.$allCheckboxes.eq(showCheckboxes[j]).show()
    }

    var len = showCheckboxes.length || 0
    var lenChecked = obj.$optionsContainer.find('.govuk-checkboxes__input:checked').length
    obj.$filterCount.html(len + (len === 1 ? obj.filterTextSingle : obj.filterTextMultiple) + ', ' + lenChecked + obj.filterTextSelected)
  }

  OptionSelect.prototype.replaceHeadingSpanWithButton = function replaceHeadingSpanWithButton () {
    /* Replace the span within the heading with a button element. This is based on feedback from Léonie Watson.
     * The button has all of the accessibility hooks that are used by screen readers and etc.
     * We do this in the JavaScript because if the JavaScript is not active then the button shouldn't
     * be there as there is no JS to handle the click event.
    */
    var $containerHead = this.$optionSelect.find('.js-container-button')
    var jsContainerHeadHTML = $containerHead.html()

    // Create button and replace the preexisting html with the button.
    var $button = $('<button>')
    $button.addClass('js-container-button app-c-option-select__title app-c-option-select__button')
    // Add type button to override default type submit when this component is used within a form
    $button.attr('type', 'button')
    $button.attr('aria-expanded', true)
    $button.attr('id', $containerHead.attr('id'))
    $button.attr('aria-controls', this.$optionsContainer.attr('id'))
    $button.html(jsContainerHeadHTML)
    $containerHead.replaceWith($button)
  }

  OptionSelect.prototype.attachCheckedCounter = function attachCheckedCounter (checkedString) {
    this.$optionSelect.find('.js-container-button')
      .after('<div class="app-c-option-select__selected-counter js-selected-counter">' + checkedString + '</div>')
  }

  OptionSelect.prototype.updateCheckedCount = function updateCheckedCount () {
    var checkedString = this.checkedString()
    var checkedStringElement = this.$optionSelect.find('.js-selected-counter')

    if (checkedString) {
      if (checkedStringElement.length) {
        checkedStringElement.text(checkedString)
      } else {
        this.attachCheckedCounter(checkedString)
      }
    } else {
      checkedStringElement.remove()
    }
  }

  OptionSelect.prototype.checkedString = function checkedString () {
    this.getAllCheckedCheckboxes()
    var count = this.checkedCheckboxes.length
    var checkedString = false
    if (count > 0) {
      checkedString = count + ' selected'
    }

    return checkedString
  }

  OptionSelect.prototype.toggleOptionSelect = function toggleOptionSelect (e) {
    if (this.isClosed()) {
      this.open()
    } else {
      this.close()
    }
    e.preventDefault()
  }

  OptionSelect.prototype.open = function open () {
    if (this.isClosed()) {
      this.$optionSelect.find('.js-container-button').attr('aria-expanded', true)
      this.$optionSelect.removeClass('js-closed')
      this.$optionSelect.addClass('js-opened')
      if (!this.$optionsContainer.prop('style').height) {
        this.setupHeight()
      }
    }
  }

  OptionSelect.prototype.close = function close () {
    this.$optionSelect.removeClass('js-opened')
    this.$optionSelect.addClass('js-closed')
    this.$optionSelect.find('.js-container-button').attr('aria-expanded', false)
  }

  OptionSelect.prototype.isClosed = function isClosed () {
    return this.$optionSelect.hasClass('js-closed')
  }

  OptionSelect.prototype.setContainerHeight = function setContainerHeight (height) {
    this.$optionsContainer.css({
      height: height
    })
  }

  OptionSelect.prototype.isCheckboxVisible = function isCheckboxVisible (index, option) {
    var $checkbox = $(option)
    var initialOptionContainerHeight = this.$optionsContainer.height()
    var optionListOffsetTop = this.$optionList.offset().top
    var distanceFromTopOfContainer = $checkbox.offset().top - optionListOffsetTop
    return distanceFromTopOfContainer < initialOptionContainerHeight
  }

  OptionSelect.prototype.getVisibleCheckboxes = function getVisibleCheckboxes () {
    var visibleCheckboxes = this.$options.filter(this.isCheckboxVisible.bind(this))
    // add an extra checkbox, if the label of the first is too long it collapses onto itself
    visibleCheckboxes = visibleCheckboxes.add(this.$options[visibleCheckboxes.length])
    return visibleCheckboxes
  }

  OptionSelect.prototype.setupHeight = function setupHeight () {
    var initialOptionContainerHeight = this.$optionsContainer.height()
    var height = this.$optionList.outerHeight(true)

    // check whether this is hidden by progressive disclosure,
    // because height calculations won't work
    if (this.$optionsContainer[0].offsetParent === null) {
      initialOptionContainerHeight = 200
      height = 200
    }

    // Resize if the list is only slightly bigger than its container
    if (height < initialOptionContainerHeight + 50) {
      this.setContainerHeight(height + 1)
      return
    }

    // Resize to cut last item cleanly in half
    var lastVisibleCheckbox = this.getVisibleCheckboxes().last()
    var position = lastVisibleCheckbox.parent()[0].offsetTop // parent element is relative
    this.setContainerHeight(position + (lastVisibleCheckbox.height() / 1.5))
  }

  Modules.OptionSelect = OptionSelect
})(window.GOVUK.Modules)
