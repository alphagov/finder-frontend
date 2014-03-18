describe('CheckboxFilter', function(){
  var filterHTML;

  beforeEach(function(){
    filter = "<div class='facet js-openable-facet' tabindex='0'>" +
    "<div class='head'>" +
      "<span class='legend'>Case type</span>" +
      "<div class='controls'><a class='clear-selected js-hidden'>clear</a><div class='toggle'></div></div>" +
    "</div>" +
    "<div class='checkbox-container'>"+
      "<ul>" +
        "<li><input type='checkbox' name='ca98'id='ca89'><label for='ca89'>CA89</label></li>" +
        "<li><input type='checkbox' name='cartels' id='cartels'><label for='cartels'>Cartels</label></li>" +
        "<li><input type='checkbox' name='criminal_cartels' id='criminal_cartels'><label for='criminal_cartels'>Criminal cartels</label>" +
          "<ul>" +
            "<li><input type='checkbox' name='markets' id='markets'><label for='markets'>Markets</label></li>" +
            "<li><input type='checkbox' name='mergers' id='mergers'><label for='mergers'>Mergers</label></li>" +
          "</ul>" +
        "</li>" +
      "</ul>" +
    "</div>" +
    "</div>";

    filterHTML = $(filter);
    $('body').append(filterHTML);
  });

  afterEach(function(){
    filterHTML.remove();
  });

  describe('listenForKeys', function(){

    it("should bind an event handler to the keypress event", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      spyOn(filter, "checkForSpecialKeys");
      filter.listenForKeys();

      // Simulate keypress
      filterHTML.trigger('keypress');
      expect(filter.checkForSpecialKeys.calls.count()).toBe(1);
    });

  });

  describe('checkForSpecialKeys', function(){

    it ("should do something if the key event passed in is a return character", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      spyOn(filter, "toggleFacet");
      filter.listenForKeys();

      // 13 is the return key
      filter.checkForSpecialKeys({keyCode:13});

      expect(filter.toggleFacet.calls.count()).toBe(1);
    });

    it ('should do nothing if the key is not return', function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      spyOn(filter, "toggleFacet");
      filter.listenForKeys();

      filter.checkForSpecialKeys({keyCode:11});
      expect(filter.toggleFacet.calls.count()).toBe(0);
    });

  });

  describe('stopListeningForKeys', function(){

    it('should remove an event handler for the keypress event', function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      spyOn(filter, "checkForSpecialKeys");
      filter.listenForKeys();
      filter.stopListeningForKeys();
      // Simulate keypress
      filterHTML.trigger('keypress');
      expect(filter.checkForSpecialKeys.calls.count()).toBe(0);
    });

  });

  describe('ensureFacetIsOpen', function(){
    it ('should always leave the facet in an open state', function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      filterHTML.addClass('closed')
      expect(filterHTML.hasClass('closed')).toBe(true);

      filter.ensureFacetIsOpen();
      expect(filterHTML.hasClass('closed')).toBe(false);
      filter.ensureFacetIsOpen();
      expect(filterHTML.hasClass('closed')).toBe(false);

    });
  });

  describe('toggleFacet', function(){

    it("should add the class 'closed' if the facet doesn't currently have it", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      filterHTML.removeClass('closed');
      expect(filterHTML.hasClass('closed')).toBe(false);
      filter.toggleFacet();
      expect(filterHTML.hasClass('closed')).toBe(true);
    });

    it("should remove the class 'closed' if the facet currently has it", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      filterHTML.addClass('closed');
      expect(filterHTML.hasClass('closed')).toBe(true);
      filter.toggleFacet();
      expect(filterHTML.hasClass('closed')).toBe(false);
    });

  });

  describe('resetCheckboxes', function(){

    it("should uncheck any checked checkboxes", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      // Check all checkboxes on this filter
      filterHTML.find('.checkbox-container input').prop("checked", true);
      expect(filterHTML.find(':checked').length).toBe($('.checkbox-container input').length);

      // Reset them
      filter.resetCheckboxes();

      // They should not be checked
      expect(filterHTML.find(':checked').length).toBe(0);
    });

  });

  describe('updateCheckboxes', function(){

    it("should update any descendant checkboxes of this checkbox to be checked if this checkbox is checked", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      var checkboxSelector = "#criminal_cartels"
      var clickEvent = {target:checkboxSelector}

      // Check one checkbox
      filterHTML.find($(checkboxSelector)).prop("checked", true);
      expect(filterHTML.find(':checked').length).toBe(1);

      // Call updateCheckbox and expect all child checkboxes to have been checked
      filter.updateCheckboxes(clickEvent);
      expect(filterHTML.find(':checked').length).toBe(3);

    });

    it("should update any descendant checkboxes of this checkbox to be unchecked if this checkbox is unchecked", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});
      var checkboxSelector = "#criminal_cartels"
      var clickEvent = {target:checkboxSelector}
      var totalCheckboxes = filterHTML.find('.checkbox-container input').length

      // Check all checkboxes
      filterHTML.find('.checkbox-container input').prop("checked", true);
      expect($(checkboxSelector).parent().find(":checked").length).toBe(3);

      // Uncheck a parent one
      filterHTML.find($(checkboxSelector)).prop("checked", false);
      expect(filterHTML.find(':checked').length).toBe(totalCheckboxes - 1);

      filter.updateCheckboxes({target:checkboxSelector});

      // Expect children to have been unchecked
      expect($(checkboxSelector).parent().find(":checked").length).toBe(0);
    });

    it("should call checkSiblings", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      spyOn(filter, "checkSiblings");
      filter.updateCheckboxes({target:'#criminal_cartels'});
      expect(filter.checkSiblings.calls.count()).toBe(1);
    });

    it("should call updateCheckboxResetter", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      spyOn(filter, "updateCheckboxResetter");
      filter.updateCheckboxes({target:'#criminal_cartels'});
      expect(filter.updateCheckboxResetter.calls.count()).toBe(1);
    });

  });


  describe('checkSiblings', function(){

    it("should set the parent of a nested checkbox to be indeterminate if not all siblings agree", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      $('#markets').prop("checked", true);
      expect(filterHTML.find(':indeterminate').length).toBe(0);
      expect(filterHTML.find(':checked').length).toBe(1);
      filter.checkSiblings($('#markets').parent(), true);
      expect(filterHTML.find(':indeterminate').length).toBe(1);
    });

    it("should set the parent of a nested checkbox to be checked if all siblings are checked", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      $('#markets').prop("checked", true);
      $('#mergers').prop("checked", true);
      expect(filterHTML.find(':indeterminate').length).toBe(0);

      expect(filterHTML.find(':checked').length).toBe(2);
      filter.checkSiblings($('#mergers').parent(), true);
      expect(filterHTML.find(':indeterminate').length).toBe(0);
      expect(filterHTML.find(':checked').length).toBe(3);

    });

    it("should set the parent of a nested checkbox to be unchecked if all siblings are unchecked", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      $('#markets').prop("checked", true);
      $('#criminal_cartels').prop("checked", true);

      // Uncheck a child checkbox
      $('#mergers').prop("checked", false);
      filter.checkSiblings($('#mergers').parent(), false);

      // Parent should have changed to be indeterminate
      expect(filterHTML.find(':indeterminate').length).toBe(1);
      expect(filterHTML.find(':checked').length).toBe(1);

      // Uncheck second child checkbox
      $('#markets').prop("checked", false);
      filter.checkSiblings($('#markets').parent(), false);

      // Parent should have changed to match agreeing children
      expect(filterHTML.find(':indeterminate').length).toBe(0);
      expect(filterHTML.find(':checked').length).toBe(0);
    });

    it("should recursively go up the checkbox tree", function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      spyOn(filter, "checkSiblings").and.callThrough();

      $('#markets').prop("checked", true);
      $('#mergers').prop("checked", true);

      filter.checkSiblings($('#mergers').parent(), true);
      expect(filter.checkSiblings.calls.count()).toBe(2);
    });
  });

  describe("updateCheckboxResetter", function(){

    it("should add the visually-hidden class to the checkbox resetter if no checkboxes are checked",function(){
      var filter = new GOVUK.CheckboxFilter({el:filterHTML});

      expect(filterHTML.find($('.clear-selected')).hasClass('js-hidden')).toBe(true);
      filter.updateCheckboxResetter();
      expect(filterHTML.find($('.clear-selected')).hasClass('js-hidden')).toBe(true);

      $('#markets').prop("checked", true);
      filter.updateCheckboxResetter();
      expect(filterHTML.find($('.clear-selected')).hasClass('js-hidden')).toBe(false);
    });

    it("should remove the visually-hidden class to the checkbox resetter if any checkboxes are checked",function(){
       var filter = new GOVUK.CheckboxFilter({el:filterHTML});

       filterHTML.find($('.clear-selected')).removeClass('js-hidden');
       expect(filterHTML.find($('.clear-selected')).hasClass('js-hidden')).toBe(false);

       filter.updateCheckboxResetter();
       expect(filterHTML.find($('.clear-selected')).hasClass('js-hidden')).toBe(true);
    });

  });

});

