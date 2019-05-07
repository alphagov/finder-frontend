window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {}; // if this ; is omitted, none of this JS runs :(

(function (Modules) {
  function Expander () {}

  Expander.prototype.start = function ($module) {
    this.$module = $module[0] // this is the expander element
    this.$toggle = this.$module.querySelector('.js-toggle')
    this.$content = this.$module.querySelector('.js-content')

    var openOnLoad = this.$module.getAttribute('data-open-on-load') === 'true'

    this.replaceTitleWithButton(openOnLoad)

    this.$module.toggleContent = this.toggleContent.bind(this)
    this.$toggleButton = this.$module.querySelector('.js-button')
    this.$toggleButton.addEventListener('click', this.$module.toggleContent)
  }

  Expander.prototype.replaceTitleWithButton = function (expanded) {
    var toggleHtml = this.$toggle.innerHTML
    var $button = document.createElement('button')

    $button.classList.add('app-c-expander__button')
    $button.classList.add('js-button')
    $button.setAttribute('type', 'button')
    $button.setAttribute('aria-expanded', expanded)
    $button.setAttribute('aria-controls', this.$content.getAttribute('id'))
    $button.innerHTML = toggleHtml

    this.$toggle.parentNode.replaceChild($button, this.$toggle)
  }

  Expander.prototype.toggleContent = function (e) {
    if (this.$toggleButton.getAttribute('aria-expanded') === 'false') {
      this.$toggleButton.setAttribute('aria-expanded', true)
      this.$content.classList.add('app-c-expander__content--visible')
    } else {
      this.$toggleButton.setAttribute('aria-expanded', false)
      this.$content.classList.remove('app-c-expander__content--visible')
    }
  }

  Modules.Expander = Expander
})(window.GOVUK.Modules)
