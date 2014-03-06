(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function CheckboxFilter(options){
    GOVUK.Proxifier.proxifyMethods(this, ['toggleFacet', 'resetCheckboxes', 'updateCheckboxResetter', 'checkSiblings']);

    this.$facet = $(options.el);
    this.$checkboxResetter = this.$facet.find('.clear-selected');
    this.$checkboxes = this.$facet.find("input[type='checkbox']");

    this.$facet.find('.head').on('click', this.toggleFacet);
    this.$checkboxResetter.on('click', this.resetCheckboxes);
    this.$checkboxes.on('click', $.proxy(this.updateCheckboxes, this));
  }


  CheckboxFilter.prototype.toggleFacet = function toggleFacet(){
    this.$facet.toggleClass('open');
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
    // Nested checkboxes effect their ancestors and children
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

  CheckboxFilter.prototype.checkSiblings = function checkSiblings(el, checked){
    var parent = el.parent().parent(),
        all = true;

    // Do all the checkboxes on this level agree?
    el.siblings().each(function(){
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
       el.parents("li").children('input[type="checkbox"]').prop({
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
