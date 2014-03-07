describe('CheckboxFilter', function() {
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

  it("should set the parent of a nested checkbox to be indeterminate if not all siblings agree", function() {
    var filter = new GOVUK.CheckboxFilter({el:'.js-openable-facet'});
    $('#markets').prop("checked", true);
    expect(filterHTML.find(':indeterminate').length).toBe(0);
    expect(filterHTML.find(':checked').length).toBe(1);
    filter.checkSiblings($('#markets').parent(), true);
    expect(filterHTML.find(':indeterminate').length).toBe(1);
  });

  it("should set the parent of a nested checkbox to be checked if all siblings are checked", function(){
    var filter = new GOVUK.CheckboxFilter({el:'.js-openable-facet'});
    $('#markets').prop("checked", true);
    $('#mergers').prop("checked", true);
    expect(filterHTML.find(':indeterminate').length).toBe(0);

    expect(filterHTML.find(':checked').length).toBe(2);
    filter.checkSiblings($('#mergers').parent(), true);
    expect(filterHTML.find(':indeterminate').length).toBe(0);
    expect(filterHTML.find(':checked').length).toBe(3);

  });

  it("should set the parent of a nested checkbox to be unchecked if all siblings are unchecked", function(){
    var filter = new GOVUK.CheckboxFilter({el:'.js-openable-facet'});
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
    var filter = new GOVUK.CheckboxFilter({el:'.js-openable-facet'});

    spyOn(filter, "checkSiblings").and.callThrough();

    $('#markets').prop("checked", true);
    $('#mergers').prop("checked", true);
    filter.checkSiblings($('#mergers').parent(), true);
    expect(filter.checkSiblings.calls.count()).toBe(2);
  });
});

