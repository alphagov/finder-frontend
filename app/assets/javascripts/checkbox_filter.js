(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function CheckboxFilter(options){
    var allowCollapsible = (typeof ieVersion == "undefined" || ieVersion > 7) ? true : false;

    this.$filter = options.el;
    this.$checkboxResetter = this.$filter.find('.clear-selected');
    this.$checkboxes = this.$filter.find("input[type='checkbox']");

    this.$checkboxResetter.on('click', this.resetCheckboxes.bind(this));

    this.$checkboxes.on('click', this.updateCheckboxResetter.bind(this));
    this.$checkboxes.on('focus', this.ensureFinderIsOpen.bind(this));

    // setupHeight is called on open, but filters containing checked checkboxes will already be open
    if (this.isOpen() || !allowCollapsible) {
      this.setupHeight();
    }

    if(allowCollapsible){
      // set up open/close listeners
      this.$filter.find('.head').on('click', this.toggleFinder.bind(this));
      this.$filter.on('focus', this.listenForKeys.bind(this));
      this.$filter.on('blur', this.stopListeningForKeys.bind(this));
    }
  }

  CheckboxFilter.prototype.setupHeight = function setupHeight(){
    var checkboxContainer = this.$filter.find('.checkbox-container');
    var checkboxList = checkboxContainer.children('.js-auto-height-inner');
    var initCheckboxContainerHeight = checkboxContainer.height();
    var height = checkboxList.height();

    if (height < initCheckboxContainerHeight) {
      // Resize if the list is smaller than its container
      checkboxContainer.height(height);

    } else if (checkboxList.height() < initCheckboxContainerHeight + 50) {
      // Resize if the list is only slightly bigger than its container
      checkboxContainer.height(checkboxList.height());
    }
  }

  CheckboxFilter.prototype.isOpen = function isOpen(){
    return !this.$filter.hasClass('closed');
  }

  CheckboxFilter.prototype.open = function open(){
    this.$filter.removeClass('closed');
    this.setupHeight();
  };

  CheckboxFilter.prototype.close = function close(){
    this.$filter.addClass('closed');
  };

  CheckboxFilter.prototype.listenForKeys = function listenForKeys(){
    this.$filter.keypress(this.checkForSpecialKeys.bind(this));
  };

  CheckboxFilter.prototype.checkForSpecialKeys = function checkForSpecialKeys(e){
    if(e.keyCode == 13) {

      // keyCode 13 is the return key.
      this.toggleFinder();
    }
  };

  CheckboxFilter.prototype.stopListeningForKeys = function stopListeningForKeys(){
    this.$filter.unbind('keypress');
  };

  CheckboxFilter.prototype.ensureFinderIsOpen = function ensureFinderIsOpen(){
    if (this.$filter.hasClass('closed')) {
      this.open();
    }
  };

  CheckboxFilter.prototype.toggleFinder = function toggleFinder(){
    if (this.$filter.hasClass('closed')) {
      this.open();
    } else {
      this.close();
    }
  };

  CheckboxFilter.prototype.resetCheckboxes = function resetCheckboxes(){
    this.$filter.find("input[type='checkbox']").prop({
      indeterminate: false,
      "checked": false
    }).trigger("change");
    this.$checkboxResetter.addClass('js-hidden');
    return false;
  };

  CheckboxFilter.prototype.updateCheckboxResetter = function updateCheckboxResetter(){
    var anyCheckedBoxes = this.$checkboxes.is(":checked"),
        checkboxResetterHidden = this.$checkboxResetter.hasClass('js-hidden');

    if (anyCheckedBoxes && checkboxResetterHidden) {
      this.$checkboxResetter.removeClass('js-hidden');
    } else if (!anyCheckedBoxes && !checkboxResetterHidden) {
      this.$checkboxResetter.addClass('js-hidden');
    }
  };

  GOVUK.CheckboxFilter = CheckboxFilter;
}());
