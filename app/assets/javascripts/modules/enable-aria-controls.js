window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function EnableAriaControls ($module) {
    this.$module = $module
  }

  EnableAriaControls.prototype.init = function () {
    var $controls = this.$module.querySelectorAll('[data-aria-controls]')
    for (var i = 0; i < $controls.length; i++) {
      var control = $controls[i].getAttribute('data-aria-controls')
      if (typeof control === 'string' && document.getElementById(control)) {
        $controls[i].setAttribute('aria-controls', control)
      }
    }
  }

  Modules.EnableAriaControls = EnableAriaControls
})(window.GOVUK.Modules)
