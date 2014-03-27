(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function CheckboxFilter(options){

    this.$facet = options.el;
    this.$checkboxResetter = this.$facet.find('.clear-selected');
    this.$checkboxes = this.$facet.find("input[type='checkbox']");

    this.$facet.find('.head').on('click', $.proxy(this.toggleFacet, this));
    this.$facet.on('focus', $.proxy(this.listenForKeys, this));
    this.$facet.on('blur', $.proxy(this.stopListeningForKeys, this));

    this.$checkboxResetter.on('click', $.proxy(this.resetCheckboxes, this));

    this.$checkboxes.on('click', $.proxy(this.updateCheckboxes, this));
    this.$checkboxes.on('focus', $.proxy(this.ensureFacetIsOpen, this));

    // setupHeight is called on open, but facets containing checked checkboxes will already be open
    if (this.isOpen()) {
      this.setupHeight();
    }
  }

  CheckboxFilter.prototype.setupHeight = function setupHeight(){
    var checkboxContainer = this.$facet.find('.checkbox-container');
    var checkboxList = checkboxContainer.children('ul');
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
    return !this.$facet.hasClass('closed');
  }

  CheckboxFilter.prototype.open = function open(){
    this.$facet.removeClass('closed');
    this.setupHeight();
  };

  CheckboxFilter.prototype.close = function close(){
    this.$facet.addClass('closed');
  };

  CheckboxFilter.prototype.listenForKeys = function listenForKeys(){
    this.$facet.keypress($.proxy(this.checkForSpecialKeys, this));
  };

  CheckboxFilter.prototype.checkForSpecialKeys = function checkForSpecialKeys(e){
    if(e.keyCode == 13) {

      // keyCode 13 is the return key.
      this.toggleFacet();
    }
  };

  CheckboxFilter.prototype.stopListeningForKeys = function stopListeningForKeys(){
    this.$facet.unbind('keypress');
  };

  CheckboxFilter.prototype.ensureFacetIsOpen = function ensureFacetIsOpen(){
    if (this.$facet.hasClass('closed')) {
      this.open();
    }
  };

  CheckboxFilter.prototype.toggleFacet = function toggleFacet(){
    if (this.$facet.hasClass('closed')) {
      this.open();
    } else {
      this.close();
    }
  };

  CheckboxFilter.prototype.resetCheckboxes = function resetCheckboxes(){
    this.$facet.find("input[type='checkbox']").prop({
      indeterminate: false,
      "checked": false
    });
    this.$checkboxResetter.addClass('js-hidden');
    return false;
  };

  CheckboxFilter.prototype.updateCheckboxes = function updateCheckboxes(e){
    // Nested checkboxes affect their ancestors and children
    var checked = $(e.target).prop("checked"),
        container = $(e.target).parent(),
        siblings = container.siblings();

    // Set all children of this checkbox to match this checkbox
    container.find('input[type="checkbox"]').prop({
      indeterminate: false,
      checked: checked
    });

    this.checkSiblings(container, checked);
    this.updateCheckboxResetter();

  };

  CheckboxFilter.prototype.checkSiblings = function checkSiblings(listitem, checked){
    var parent = listitem.parent().parent(),
        all = true;

    // Do all the checkboxes on this level agree?
    listitem.siblings().each(function(){
      return all = ($(this).children('input[type="checkbox"]').prop("checked") === checked);
    });

    if (all) {
      /*
        If all the checkboxes on this level agree set their shared parent to be the same.
        Then push the changes up the checkbox tree.
      */
      parent.children('input[type="checkbox"]').prop({
        indeterminate: false,
        checked: checked
      });
      this.checkSiblings(parent, all);

    } else {
       // if the checkboxes on this level disagree then set the parent to indeterminate
       listitem.parents('li').children('input[type="checkbox"]').prop({
         indeterminate: true,
         checked: false
       });
     }
   }

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
