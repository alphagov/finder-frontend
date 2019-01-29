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
      var $submitMessage = $this.find('.js-submit-message');

      $openFormButton.on('click', function(e) {
        e.preventDefault();
        $promptQuestions.toggleClass(jsHiddenClass);
        $form.toggleClass(jsHiddenClass);
        $form.find('textarea')[0].focus();
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
        }).done(function () {
          trackEvent($form);
          $form.toggleClass(jsHiddenClass);
          $submitMessage.toggleClass(jsHiddenClass).focus();
          enableSubmitFormButton($form);
        }).fail(function () {
          trackEvent($form);
          showError($form);
          enableSubmitFormButton($form);
        });
      });
    };

    function trackEvent($form) {
      var trackEventParams = {
        category: $form.data('track-category'),
        action: $form.data('track-action')
      }

      if (GOVUK.analytics && GOVUK.analytics.trackEvent) {
        GOVUK.analytics.trackEvent(trackEventParams.category, trackEventParams.action);
      }
    }

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
