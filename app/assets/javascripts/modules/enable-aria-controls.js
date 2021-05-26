window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (GOVUK) {
  'use strict'

  GOVUK.Modules.EnableAriaControls = function EnableAriaControls () {
    this.start = function (element) {
      var $controls = element[0].querySelectorAll('[data-aria-controls]')
      for (var i = 0; i < $controls.length; i++) {
        var control = $controls[i].getAttribute('data-aria-controls')
        if (typeof control === 'string' && document.getElementById(control)) {
          $controls[i].setAttribute('aria-controls', control)
        }
      }
    }
  }
})(window.GOVUK)
