(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function CheckboxFilter(options){
    GOVUK.Proxifier.proxifyMethods(this, ['toggleFacet', 'resetCheckboxes', 'updateCheckboxResetter', 'checkSiblings', 'listenForKeys','stopListeningForKeys', 'ensureFacetIsOpen']);

    this.$facet = options.el;
    this.$checkboxResetter = this.$facet.find('.clear-selected');
    this.$checkboxes = this.$facet.find("input[type='checkbox']");

    this.$facet.find('.head').on('click', this.toggleFacet);
    this.$facet.on('focus', this.listenForKeys);
    this.$facet.on('blur', this.stopListeningForKeys);

    this.$checkboxResetter.on('click', this.resetCheckboxes);

    this.$checkboxes.on('click', $.proxy(this.updateCheckboxes,this));
    this.$checkboxes.on('focus', this.ensureFacetIsOpen);
  }

  CheckboxFilter.prototype.listenForKeys = function listenForKeys(){
    this.$facet.keypress($.proxy(this.checkForSpecialKeys, this));
  };

  CheckboxFilter.prototype.checkForSpecialKeys = function checkForSpecialKeys(e){
    if(e.keyCode == 13) {
      this.toggleFacet();
    }
  };

  CheckboxFilter.prototype.stopListeningForKeys = function stopListeningForKeys(){
    this.$facet.unbind('keypress');
  };

  CheckboxFilter.prototype.ensureFacetIsOpen = function ensureFacetIsOpen(){
    if (this.$facet.hasClass('closed')) {
      this.$facet.removeClass('closed');
    }
  };

  CheckboxFilter.prototype.toggleFacet = function toggleFacet(){
    this.$facet.toggleClass('closed');
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
