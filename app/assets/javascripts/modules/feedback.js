window.GOVUK = window.GOVUK || {};
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (GOVUK) {
  "use strict";

  var jsHiddenClass = 'js-hidden';

  GOVUK.Modules.BusinessFinderFeedback = function () {

    this.start = function ($this) {

      var $form = $this.find('.js-feedback-form');
      var $promptQuestions = $this.find('.js-prompt');
      var $openFormButton = $this.find('.js-open-form');
      var $submitYesButton = $this.find('.js-submit-yes');
      var $successMessage = $this.find('.js-success-message');
      var $submitMessage = $this.find('.js-submit-message');

      $openFormButton.on('click', function(e) {
        e.preventDefault();
        $promptQuestions.toggleClass(jsHiddenClass);
        $form.toggleClass(jsHiddenClass)
      });

      $submitYesButton.on('click', function(e) {
        e.preventDefault();
        $promptQuestions.toggleClass(jsHiddenClass);
        // Where do we want to submit this data to?
        $successMessage.toggleClass(jsHiddenClass);
      });

      $form.on('submit', function(e) {
        e.preventDefault();
        $.ajax({
          type: "POST",
          url: $form.attr('action'),
          dataType: "json",
          data: $form.serialize(),
          beforeSend: disableSubmitFormButton($form),
          timeout: 6000
        }).done(function (xhr) {
          // Remove these!
          console.log("success!");
          console.log(xhr);
          $form.toggleClass(jsHiddenClass);
          $submitMessage.toggleClass(jsHiddenClass);
          enableSubmitFormButton($form);
        }).fail(function () {
          showError($form);
          enableSubmitFormButton($form);
        });
      });
    };

    function disableSubmitFormButton ($form) {
      $form.find('button[type="submit"]').prop('disabled', true);
    }

    function enableSubmitFormButton ($form) {
      $form.find('button[type="submit"]').removeAttr('disabled');
    }

    function showError ($form) {
      var $errorBox = $form.find('#feedback-error').parent();
      $errorBox.removeClass(jsHiddenClass).focus();
    }
  };
})(window.GOVUK);
