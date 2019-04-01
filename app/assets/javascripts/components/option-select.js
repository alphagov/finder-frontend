(function ($) {
  "use strict";
  window.GOVUK = window.GOVUK || {};

  function OptionSelect(options){
    /* This JavaScript provides two functional enhancements to option-select components:
      1) A count that shows how many results have been checked in the option-container
      2) Open/closing of the list of checkboxes - this is not provided for ie6 and 7 as the performance is too janky.
    */

    this.$optionSelect = options.$el;
    this.$options = this.$optionSelect.find("input[type='checkbox']");
    this.$optionsContainer = this.$optionSelect.find('.js-options-container');
    this.$optionList = this.$optionsContainer.children('.js-auto-height-inner');
    this.$allCheckboxes = this.$optionsContainer.find('.govuk-checkboxes__item');
    this.hasFilter = this.$optionSelect.data('filter-element') || "";
    this.checkedCheckboxes = [];

    if (this.hasFilter.length) {
      var filterEl = document.createElement('div');
      filterEl.innerHTML = this.hasFilter;

      $('<div class="app-c-option-select__filter"/>')
        .html(filterEl.childNodes[0].nodeValue)
        .prependTo(this.$optionList);

      this.$filter = this.$optionsContainer.find('input[name="option-select-filter"]');
      this.$filterCount = $('#' + this.$filter.attr('aria-describedby'));
      this.filterTextSingle = ' ' + this.$filterCount.data('single');
      this.filterTextMultiple = ' ' + this.$filterCount.data('multiple');
      this.checkboxLabels = [];
      this.filterTimeout = 0;
      var that = this;

      this.getAllCheckedCheckboxes();
      this.$allCheckboxes.each(function() {
        that.checkboxLabels.push(that.cleanString($(this).text()));
      });

      this.$filter.on('keyup', function(e) {
        e.stopPropagation();
        var ENTER_KEY = 13;

        if(e.keyCode !== ENTER_KEY) {
          clearTimeout(that.filterTimeout);
          that.filterTimeout = setTimeout(function(obj){
            that.doFilter(obj);
          }, 300, that);
        } else {
          e.preventDefault(); // prevents finder forms from being submitted when user presses ENTER
        }
      });
    }

    this.attachCheckedCounter();

    // Performance in ie 6/7 is not good enough to support animating the opening/closing
    // so do not allow option-selects to be collapsible in this case
    var allowCollapsible = (typeof ieVersion == "undefined" || ieVersion > 7) ? true : false;
    if(allowCollapsible){

      // Attach listener to update checked count
      this.$optionSelect.on('change', "input[type='checkbox']", this.updateCheckedCount.bind(this));

      // Replace div.container-head with a button
      this.replaceHeadWithButton();

      // Add js-collapsible class to parent for CSS
      this.$optionSelect.addClass('js-collapsible');

      // Add open/close listeners
      this.$optionSelect.find('.js-container-head').on('click', this.toggleOptionSelect.bind(this));

      if (this.$optionSelect.data('closed-on-load') === true) {
        this.close();
      }
      else {
        this.setupHeight();
      }
    }
  }

  OptionSelect.prototype.cleanString = function cleanString(text) {
    text = text.replace(/&/g, 'and');
    text = text.replace(/[’',:–-]/g,''); // remove punctuation characters
    return text.trim().replace(/\s\s+/g, ' ').toLowerCase(); // replace multiple spaces with one
  };

  OptionSelect.prototype.getAllCheckedCheckboxes = function getAllCheckedCheckboxes() {
    this.checkedCheckboxes = [];
    var that = this;

    this.$allCheckboxes.each(function(i) {
      if ($(this).find('input[type=checkbox]').is(':checked')) {
        that.checkedCheckboxes.push(i);
      }
    });
  };

  OptionSelect.prototype.doFilter = function doFilter(obj){
    var filterBy = obj.cleanString(obj.$filter.val());
    var showCheckboxes = obj.checkedCheckboxes.slice();

    for (var i = 0; i < obj.$allCheckboxes.length; i++) {
      if (showCheckboxes.indexOf(i) == -1 && obj.checkboxLabels[i].search(filterBy) !== -1) {
        showCheckboxes.push(i);
      }
    }

    obj.$allCheckboxes.hide();
    for (var j = 0; j < showCheckboxes.length; j++) {
      obj.$allCheckboxes.eq(showCheckboxes[j]).show();
    }

    var len = showCheckboxes.length || 0;
    obj.$filterCount.html(len + (len == 1 ? obj.filterTextSingle : obj.filterTextMultiple));
  };

  OptionSelect.prototype.replaceHeadWithButton = function replaceHeadWithButton(){
    /* Replace the div at the head with a button element. This is based on feedback from Léonie Watson.
     * The button has all of the accessibility hooks that are used by screen readers and etc.
     * We do this in the JavaScript because if the JavaScript is not active then the button shouldn't
     * be there as there is no JS to handle the click event.
    */
    var $containerHead = this.$optionSelect.find('.js-container-head');
    var jsContainerHeadHTML = $containerHead.html();

    // Create button and replace the preexisting html with the button.
    var $button = $('<button>');
    $button.addClass('js-container-head app-c-option-select__button');
    //Add type button to override default type submit when this component is used within a form
    $button.attr('type', 'button');
    $button.attr('aria-expanded', true);
    $button.attr('aria-controls', this.$optionsContainer.attr('id'));
    $button.html(jsContainerHeadHTML);
    $containerHead.replaceWith($button);

  };

  OptionSelect.prototype.attachCheckedCounter = function attachCheckedCounter(){
    this.$optionSelect.find('.js-container-head').append('<div class="govuk-!-font-size-14 js-selected-counter">'+this.checkedString()+'</div>');
  };

  OptionSelect.prototype.updateCheckedCount = function updateCheckedCount(){
    this.$optionSelect.find('.js-selected-counter').text(this.checkedString());
  };

  OptionSelect.prototype.checkedString = function checkedString(){
    this.getAllCheckedCheckboxes();
    var count = this.checkedCheckboxes.length;
    var checkedString = "";
    if (count > 0){
      checkedString = count+" selected";
    }

    return checkedString;
  };


  OptionSelect.prototype.toggleOptionSelect = function toggleOptionSelect(e){
    if (this.isClosed()) {
      this.open();
    } else {
      this.close();
    }
    e.preventDefault();
  };

  OptionSelect.prototype.open = function open(){
    if (this.isClosed()) {
      this.$optionSelect.find('.js-container-head').attr('aria-expanded', true);
      this.$optionSelect.removeClass('js-closed');
      if (!this.$optionsContainer.prop('style').height) {
        this.setupHeight();
      }
    }
  };

  OptionSelect.prototype.close = function close(){
    this.$optionSelect.addClass('js-closed');
    this.$optionSelect.find('.js-container-head').attr('aria-expanded', false);
  };

  OptionSelect.prototype.isClosed = function isClosed(){
    return this.$optionSelect.hasClass('js-closed');
  };

  OptionSelect.prototype.setContainerHeight = function setContainerHeight(height){
    this.$optionsContainer.css({
      'height': height
    });
  };

  OptionSelect.prototype.isCheckboxVisible = function isCheckboxVisible(index, option){
    var $checkbox = $(option);
    var initialOptionContainerHeight = this.$optionsContainer.height();
    var optionListOffsetTop = this.$optionList.offset().top;
    var distanceFromTopOfContainer = $checkbox.offset().top - optionListOffsetTop;
    return distanceFromTopOfContainer < initialOptionContainerHeight;
  };

  OptionSelect.prototype.getVisibleCheckboxes = function getVisibleCheckboxes(){
    var visibleCheckboxes = this.$options.filter(this.isCheckboxVisible.bind(this));
    // add an extra checkbox, if the label of the first is too long it collapses onto itself
    visibleCheckboxes = visibleCheckboxes.add(this.$options[visibleCheckboxes.length]);
    return visibleCheckboxes;
  };

  OptionSelect.prototype.setupHeight = function setupHeight(){
    var initialOptionContainerHeight = this.$optionsContainer.height();
    var height = this.$optionList.outerHeight(true);

    // check whether this is hidden by progressive disclosure,
    // because height calculations won't work
    if (this.$optionsContainer[0].offsetParent === null) {
      initialOptionContainerHeight = 200;
      height = 200;
    }

    // Resize if the list is only slightly bigger than its container
    if (height < initialOptionContainerHeight + 50) {
      this.setContainerHeight(height + 1);
      return;
    }

    // Resize to cut last item cleanly in half
    var lastVisibleCheckbox = this.getVisibleCheckboxes().last();
    var position = lastVisibleCheckbox.parent().position().top; // parent element is relative
    this.setContainerHeight(position + (lastVisibleCheckbox.height() / 1.5));
  };

  GOVUK.OptionSelect = OptionSelect;

  // Instantiate an option select for each one found on the page
  var filters = $('.app-c-option-select').map(function(){
    return new GOVUK.OptionSelect({$el:$(this)});
  });
})(jQuery);
