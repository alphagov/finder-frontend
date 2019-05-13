/* eslint-env jquery */

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (GOVUK) {
  'use strict'

  GOVUK.Modules.EnableAriaControls = function EnableAriaControls () {
    this.start = function (element) {
      element.find('[data-aria-controls]').each(enableAriaControls)

      function enableAriaControls () {
        var controls = $(this).data('aria-controls')
        if (typeof controls === 'string' && $('#' + controls).length > 0) {
          $(this).attr('aria-controls', controls)
        }
      }
    }
  }
})(window.GOVUK)
