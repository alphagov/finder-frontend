(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function CheckboxFilter(options) {
    GOVUK.Proxifier.proxifyMethods(this, ['toggleFacet', 'resetCheckboxes']);

    this.$facet = $(options.el);
    this.$checkboxResetter = this.$facet.find('.clear-selected');
    this.$checkboxes = this.$facet.find("input[type='checkbox']");

    this.$facet.find('.head').on('click', this.toggleFacet);
    this.$checkboxResetter.on('click', this.resetCheckboxes);
    this.$checkboxes.on('click', this.updateCheckboxes);
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

  CheckboxFilter.prototype.updateCheckboxes = function updateCheckboxes(){
    /* Nested checkboxes effect their ancestors and children */
    var checked = $(this).prop("checked"),
        container = $(this).parent(),
        siblings = container.siblings();

    // Set all children of this checkbox to match this checkbox
    container.find('input[type="checkbox"]').prop({
      indeterminate: false,
      checked: checked
    });


    function checkSiblings(el){
      var parent = el.parent().parent(),
          all = true;

      /* Do all the checkboxes on this level agree? */
      el.siblings().each(function(){
        return all = ($(this).children('input[type="checkbox"]').prop("checked") === checked);
      });

      if (all && checked) {
        /*
          If all the checkboxes on this level are checked set their shared parent to be checked.
          Then push the changes up the checkbox tree.
        */
        parent.children('input[type="checkbox"]').prop({
          indeterminate: false,
          checked: checked
        });

        checkSiblings(parent);
      } else if (all && !checked) {
        /*
          If all the checkboxes on this level are unchecked set their shared parent to be unchecked.
          Then push the changes up the checkbox tree.
        */
         parent.children('input[type="checkbox"]').prop("checked", checked);
         parent.children('input[type="checkbox"]').prop("indeterminate", false);
         checkSiblings(parent);
       } else {
         // if the checkboxes on this level disagree then set the parent to indeterminate
         el.parents("li").children('input[type="checkbox"]').prop({
           indeterminate: true,
           checked: false
         });
       }
    }
    checkSiblings(container)
  };

  GOVUK.CheckboxFilter = CheckboxFilter;
}());
