describe('GOVUK.OptionSelect', function() {

  var $optionSelectHTML, optionSelect;

  beforeEach(function(){

    optionSelectFixture = '<div class="app-c-option-select">'+
      '<div class="container-head js-container-head">'+
        '<div class="option-select-label">Market sector</div>'+
      '</div>'+
      '<div class="options-container">'+
        '<div class="js-auto-height-inner">'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="aerospace" id="aerospace" type="checkbox" class="govuk-checkboxes__input" data-track-action="market-sector" data-track-label="aerospace" data-track-value="1">'+
            '<label class="govuk-label govuk-checkboxes__label" for="aerospace">Aerospace</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="agriculture-environment-and-natural-resources" id="agriculture-environment-and-natural-resources" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="agriculture-environment-and-natural-resources">Agriculture, environment, natural resources, agriculture, environment, natural resources, agriculture, environment, natural resources, agriculture, environment, natural resources, agriculture, environment, natural resources, agriculture, environment and natural resources.</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="building-and-construction" id="building-and-construction" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="building-and-construction">Building and construction</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="chemicals" id="chemicals" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="chemicals">Chemicals</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="clothing-footwear-and-fashion" id="clothing-footwear-and-fashion" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="clothing-footwear-and-fashion">Clothing, footwear and fashion</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="defence" id="defence" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="defence">Defence</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="distribution-and-service-industries" id="distribution-and-service-industries" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="distribution-and-service-industries">Distribution and Service Industries</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="electronics-industry" id="electronics-industry" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="electronics-industry">Electronics Industry</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="energy" id="energy" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="energy">Energy</label>'+
          '</div>'+
          '<div class="gem-c-checkbox govuk-checkboxes__item">'+
            '<input name="market_sector[]" value="engineering" id="engineering" type="checkbox" class="govuk-checkboxes__input">'+
            '<label class="govuk-label govuk-checkboxes__label" for="engineering">Engineering</label>'+
          '</div>'+
        '</div>'+
      '</div>';

    $optionSelectHTML = $(optionSelectFixture);
    $('body').append($optionSelectHTML);
    optionSelect = new GOVUK.OptionSelect({$el:$optionSelectHTML});
  });

  afterEach(function(){
    $optionSelectHTML.remove();
  });

  it('instantiates a closed option-select if data-closed-on-load is true', function(){
    closedOnLoadFixture = '<div class="app-c-option-select" data-closed-on-load=true>' +
                            '<div class="container-head js-container-head"></div>' +
                          '</div>';
    $closedOnLoadFixture = $(closedOnLoadFixture);

    $('body').append($closedOnLoadFixture);
    optionSelect = new GOVUK.OptionSelect({$el:$closedOnLoadFixture});
    expect(optionSelect.isClosed()).toBe(true);
    expect($closedOnLoadFixture.find('button').attr('aria-expanded')).toBe('false');
  });

  it('instantiates an open option-select if data-closed-on-load is false', function(){
    openOnLoadFixture = '<div class="app-c-option-select" data-closed-on-load=false>' +
                            '<div class="container-head js-container-head"></div>' +
                          '</div>';
    $openOnLoadFixture = $(openOnLoadFixture);

    $('body').append($openOnLoadFixture);
    optionSelect = new GOVUK.OptionSelect({$el:$openOnLoadFixture});
    expect(optionSelect.isClosed()).toBe(false);
    expect($openOnLoadFixture.find('button').attr('aria-expanded')).toBe('true');
  });

  it('instantiates an open option-select if data-closed-on-load is not present', function(){
    openOnLoadFixture = '<div class="app-c-option-select">' +
                          '<div class="container-head js-container-head"></div>' +
                        '</div>';
    $openOnLoadFixture = $(openOnLoadFixture);

    $('body').append($openOnLoadFixture);
    optionSelect = new GOVUK.OptionSelect({$el:$openOnLoadFixture});
    expect(optionSelect.isClosed()).toBe(false);
    expect($openOnLoadFixture.find('button').attr('aria-expanded')).toBe('true');
  });

  it ('sets the height of the options container as part of initialisation', function(){
    expect($optionSelectHTML.find('.options-container').attr('style')).toContain('height');
  });

  it ('doesn\'t set the height of the options container as part of initialisation if closed-on-load is true', function(){
    closedOnLoadFixture = '<div class="app-c-option-select" data-closed-on-load=true>' +
                            '<div class="options-container"></div>' +
                          '</div>';
    $closedOnLoadFixture = $(closedOnLoadFixture);

    $('body').append($closedOnLoadFixture);
    optionSelect = new GOVUK.OptionSelect({$el:$closedOnLoadFixture});
    expect($closedOnLoadFixture.find('.options-container').attr('style')).not.toContain('height');
  });

  describe('replaceHeadWithButton', function(){
    it ("replaces the `div.container-head` with a button", function(){
      expect($optionSelectHTML.find('button')).toBeDefined();
    })
  });

  describe('toggleOptionSelect', function(){
    it("calls optionSelect.close() if the optionSelect is currently open", function(){
      $optionSelectHTML.removeClass('js-closed');
      spyOn(optionSelect, "close");
      optionSelect.toggleOptionSelect(jQuery.Event("click"));
      expect(optionSelect.close.calls.count()).toBe(1);
    });

    it("calls optionSelect.open() if the optionSelect is currently closed", function(){
      $optionSelectHTML.addClass('js-closed');
      spyOn(optionSelect, "open");
      optionSelect.toggleOptionSelect(jQuery.Event("click"));
      expect(optionSelect.open.calls.count()).toBe(1);
    });
  });

  describe('open', function(){
    beforeEach(function(){
      spyOn(optionSelect, "isClosed").and.returnValue(true);
    });

    it ('calls isClosed() and opens if isClosed is true', function(){
      optionSelect.open();
      expect(optionSelect.isClosed.calls.count()).toBe(1);
      expect($optionSelectHTML.hasClass('js-closed')).toBe(false);
    });

    it('opens the option-select', function(){
      optionSelect.open();
      expect($optionSelectHTML.hasClass('js-closed')).toBe(false);
    });

    it ('calls setupHeight() if a height has not been set', function(){
      $optionSelectHTML.find('.options-container').attr('style', '');
      spyOn(optionSelect, "setupHeight");
      optionSelect.open();
      expect(optionSelect.setupHeight.calls.count()).toBe(1);
    });

    it ('doesn\'t call setupHeight() if a height has already been set', function(){
      optionSelect.setContainerHeight(100);
      spyOn(optionSelect, "setupHeight");
      optionSelect.open();
      expect(optionSelect.setupHeight.calls.count()).toBe(0);
    });

    it ('updates aria-expanded to true', function(){
      $optionSelectHTML.find('button').attr('aria-expanded', 'false');
      optionSelect.open();
      expect($optionSelectHTML.find('button').attr('aria-expanded')).toBe('true');
    });

  });

  describe('close', function(){
    it('closes the option-select', function(){
      optionSelect.open();
      expect(optionSelect.isClosed()).toBe(false);
      optionSelect.close();
      expect(optionSelect.isClosed()).toBe(true);
    });

    it ('updates aria-expanded to false', function(){
      $optionSelectHTML.find('button').attr('aria-expanded', 'true');
      optionSelect.close();
      expect($optionSelectHTML.find('button').attr('aria-expanded')).toBe('false');
    });
  });

  describe('isClosed', function(){
    it('returns true if the optionSelect has the class `.js-closed`', function(){
      $optionSelectHTML.addClass('js-closed');
      expect(optionSelect.isClosed()).toBe(true);
    });

    it('returns false if the optionSelect doesnt have the class `.js-closed`', function(){
      $optionSelectHTML.removeClass('js-closed');
      expect(optionSelect.isClosed()).toBe(false);
    });
  });

  describe ('setContainerHeight', function(){

    it('can have its height set', function(){
      optionSelect.setContainerHeight(200);
      expect(optionSelect.$optionsContainer.height()).toBe(200);
    });

    it('still works even if the container has a max-height', function(){
      optionSelect.$optionsContainer.css("max-height", 100);
      expect(optionSelect.$optionsContainer.height()).toBeLessThan(101);
      optionSelect.setContainerHeight(200);
      expect(optionSelect.$optionsContainer.height()).toBe(200);
    });
  });

  describe ('isLabelVisible', function(){
    var firstLabel, lastLabel;

    beforeEach(function(){
      optionSelect.setContainerHeight(100);
      optionSelect.$optionsContainer.width(100);
      firstLabel = optionSelect.$labels[0];
      lastLabel = optionSelect.$labels[optionSelect.$labels.length -1];
    });

    it('returns true if a label is visible', function(){
      expect(optionSelect.isLabelVisible.call(optionSelect, 0, firstLabel)).toBe(true);
    });

    it('returns true if a label is outside its container', function(){
      expect(optionSelect.isLabelVisible.call(optionSelect, 0, lastLabel)).toBe(false);
    });

  });

  describe ('getVisibleLabels', function(){
    var visibleLabels, lastLabelForAttribute, lastVisibleLabelForAttribute;

    it('returns all the labels if the container doesn\'t overflow', function(){
      expect(optionSelect.$labels.length).toBe(optionSelect.getVisibleLabels().length);
    });

    it('only returns some of the first labels if the container\'s dimensions are constricted', function(){
      optionSelect.setContainerHeight(100);
      optionSelect.$optionsContainer.width(100);

      visibleLabels = optionSelect.getVisibleLabels();
      expect(visibleLabels.length).toBeLessThan(optionSelect.$labels.length);

      lastLabelForAttribute = optionSelect.$labels[optionSelect.$labels.length - 1].getElementsByClassName('govuk-label')[0].getAttribute("for");
      lastVisibleLabelForAttribute = visibleLabels[visibleLabels.length - 1].getElementsByClassName('govuk-label')[0].getAttribute("for");
      expect(lastLabelForAttribute).not.toBe(lastVisibleLabelForAttribute);
    });
  });

  describe ('setupHeight', function(){
    var checkboxContainerHeight, stretchMargin;

    beforeEach(function(){

      // Set some visual properties which are done in the CSS IRL
      $checkboxList = $optionSelectHTML.find('.options-container');
      $checkboxList.css({
        'height': 200,
        'position': 'relative',
        'overflow': 'scroll'
      });
      $listItems = $checkboxList.find('label');
      $listItems.css({
        'display': 'block'
      });

      $checkboxListInner = $checkboxList.find(' > .js-auto-height-inner');
      listItem = "<input type='checkbox' name='ca98'id='ca89'><label for='ca89'>CA89</label>";
    });

    it('expands the checkbox-container to fit checkbox list if the list is < 50px larger than the container', function(){
      $checkboxListInner.height(201);
      optionSelect.setupHeight();

      // Wrapping HTML should adjust to fit inner height
      expect($checkboxList.height()).toBe($checkboxListInner.height());
    });

    it('expands the checkbox-container just enough to cut the last visible item in half horizontally, if there are many items', function(){
      $checkboxList.css({
        "max-height": 200,
        "width": 600
      });
      optionSelect.setupHeight();

      // Wrapping HTML should not stretch as 251px is too big.
      expect($checkboxList.height()).toBeGreaterThan(100);
    });

  });

  describe('listenForKeys', function(){

    it('binds an event handler to the keypress event', function(){
      spyOn(optionSelect, "checkForSpecialKeys");
      optionSelect.listenForKeys();

      // Simulate keypress
      $optionSelectHTML.trigger('keypress');
      expect(optionSelect.checkForSpecialKeys.calls.count()).toBe(1);
    });

  });

  describe('checkForSpecialKeys', function(){

    it ("calls toggleOptionSelect() if the key event passed in is a return character", function(){
      spyOn(optionSelect, "toggleOptionSelect");
      optionSelect.listenForKeys();

      // 13 is the return key
      optionSelect.checkForSpecialKeys({keyCode:13});

      expect(optionSelect.toggleOptionSelect.calls.count()).toBe(1);
    });

    it ('does nothing if the key is not return', function(){
      spyOn(optionSelect, "toggleOptionSelect");
      optionSelect.listenForKeys();

      optionSelect.checkForSpecialKeys({keyCode:11});
      expect(optionSelect.toggleOptionSelect.calls.count()).toBe(0);
    });

  });

  describe('stopListeningForKeys', function(){

    it('removes the event handler for the keypress event', function(){
      spyOn(optionSelect, "checkForSpecialKeys");
      optionSelect.listenForKeys();
      optionSelect.stopListeningForKeys();

      // Simulate keypress
      $optionSelectHTML.trigger("keypress");
      expect(optionSelect.checkForSpecialKeys.calls.count()).toBe(0);
    });

  });


  describe('fireChangedAnalyticsEvent', function(){

    beforeEach(function(){
      GOVUK.analytics = {
        trackEvent: function(){}
      }

      spyOn(GOVUK.analytics, 'trackEvent');

      $checkbox = $optionSelectHTML.find(":input#aerospace");
    });

    it('fires a filterClicked Google Analytics event for the change event if the checkbox is checked', function(){
      $checkbox.trigger("click");
      expect($checkbox.is(":checked")).toBe(true);
      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith("filterClicked", "market-sector", { label: "aerospace", value: 1 });
    });

    it('fires a filterRemoved Google Analytics event for the change event if the checkbox is unchecked', function(){
      $checkbox.trigger("click");
      expect($checkbox.is(":checked")).toBe(true);

      GOVUK.analytics.trackEvent.calls.reset();

      $checkbox.trigger("click");
      expect($checkbox.is(":checked")).toBe(false);
      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith("filterRemoved", "market-sector", { label: "aerospace", value: 1 });
    });
  });

});
