describe('aria-controls enabler', function () {
  var GOVUK = window.GOVUK
  var enableAriaControls

  it('ignores aria-controls if the referenced element isn’t present', function () {
    var $element = $('<div><div data-aria-controls="not-on-page"></div></div>')

    enableAriaControls = new GOVUK.Modules.EnableAriaControls($element[0])
    enableAriaControls.init()

    expect($($element).find('[aria-controls]').length).toBe(0)
  })

  it('adds aria-controls attributes if the referenced element is on the page', function () {
    var $referenced = $('<div id="on-page"></div>')
    $('body').append($referenced)

    var $element = $('<div><div data-aria-controls="on-page"></div></div>')

    enableAriaControls = new GOVUK.Modules.EnableAriaControls($element[0])
    enableAriaControls.init()

    expect($('#on-page').length).toBe(1)
    expect($($element).find('[aria-controls="on-page"]').length).toBe(1)

    $referenced.remove()
  })
})
