describe("liveSearch", function(){
  var $form, $results, _supportHistory, liveSearch, $autocompleteForm;
  var dummyResponse = {
    "total":1,
    "pluralised_document_noun":"reports",
    "applied_filters":" \u003Cstrong\u003ECommercial - rotorcraft \u003Ca href='?format=json\u0026keywords='\u003E×\u003C/a\u003E\u003C/strong\u003E",
    "any_filters_applied":true,
    "atom_url": "http://an-atom-url.atom?some-query-param",
    "documents":[
      {
        "document": {
          "title":"Test report",
          "slug":"aaib-reports/test-report",
          "metadata":[
            {
              "label":"Aircraft category",
              "value":"General aviation - rotorcraft",
              "is_text":true
            },{
              "label":"Report type",
              "value":"Annual safety report",
              "is_text":true
            },{
              "label":"Occurred",
              "is_date":true,
              "machine_date":"2013-11-03",
              "human_date":"3 November 2013"
            }
          ]
        },
        "document_index": 1
      }
    ]
  };

  beforeEach(function () {
    $form = $('<form action="/somewhere" class="js-live-search-form"><input type="checkbox" name="field" value="sheep" checked><input type="submit" value="Filter results" class="button js-live-search-fallback"/></form>');
    $results = $('<div class="js-live-search-results-block"></div>');
    $count = $('<div aria-live="assertive" id="js-search-results-info"><p class="result-info"></p></div>');
    $atomAutodiscoveryLink = $("<link href='http://an-atom-url.atom' rel='alternate' title='ATOM' type='application/atom+xml'>");
    $('body').append($form).append($results).append($atomAutodiscoveryLink);

    _supportHistory = GOVUK.support.history;
    GOVUK.support.history = function(){ return true; };
    GOVUK.analytics = { trackPageview: function (){ } };

    liveSearch = new GOVUK.LiveSearch({$form: $form, $results: $results, $atomAutodiscoveryLink:$atomAutodiscoveryLink});
  });

  afterEach(function(){
    $form.remove();
    $results.remove();
    GOVUK.support.history = _supportHistory;
  });

  it("should save initial state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
  });

  it("should detect a new state", function(){
    expect(liveSearch.isNewState()).toBe(false);
    $form.find('input').prop('checked', false);
    expect(liveSearch.isNewState()).toBe(true);
  });

  it("should update state to current state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    liveSearch.saveState();
    expect(liveSearch.state).toEqual([]);
  });

  it("should update state to passed in state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    liveSearch.saveState({ my: "new", state: "object"});
    expect(liveSearch.state).toEqual({ my: "new", state: "object"});
  });

  it("should not request new results if they are in the cache", function(){
    liveSearch.resultCache["more=results"] = "exists";
    liveSearch.state = { more: "results" };
    spyOn(liveSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    liveSearch.updateResults();
    expect(liveSearch.displayResults).toHaveBeenCalled();
    expect(jQuery.ajax).not.toHaveBeenCalled();
  });

  it("should return a promise like object if results are in the cache", function(){
    liveSearch.resultCache["more=results"] = "exists";
    liveSearch.state = { more: "results" };
    spyOn(liveSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    var promise = liveSearch.updateResults();
    expect(typeof promise.done).toBe('function');
  });

  it("should return a promise like object if results aren't in the cache", function(){
    liveSearch.state = { not: "cached" };
    spyOn(liveSearch, 'displayResults');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    liveSearch.updateResults();
    expect(jQuery.ajax).toHaveBeenCalledWith({url: '/somewhere.json', data: {not: "cached"}, searchState : 'not=cached'});
    expect(ajaxCallback.done).toHaveBeenCalled();
    ajaxCallback.done.calls.mostRecent().args[0]('response data');
    expect(liveSearch.displayResults).toHaveBeenCalled();
    expect(liveSearch.resultCache['not=cached']).toBe('response data');
  });

  it("should show error indicator when error loading new results", function(){
    liveSearch.state = { not: "cached" };
    spyOn(liveSearch, 'displayResults');
    spyOn(liveSearch, 'showErrorIndicator');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    liveSearch.updateResults();
    ajaxCallback.error.calls.mostRecent().args[0]();
    expect(liveSearch.showErrorIndicator).toHaveBeenCalled();
  });

  it("should return cache items for current state", function(){
    liveSearch.state = { not: "cached" };
    expect(liveSearch.cache('some-slug')).toBe(undefined);
    liveSearch.cache('some-slug', 'something in the cache');
    expect(liveSearch.cache('some-slug')).toBe('something in the cache');
  });

  describe("should not display out of date results", function(){

    it('should not update the results if the state associated with these results is not the current state of the page', function(){
      liveSearch.state = 'cma-cases.json?keywords=123';
      spyOn(liveSearch.$resultsBlock, 'mustache');
      liveSearch.displayResults(dummyResponse, 'made up state');
      expect(liveSearch.$resultsBlock.mustache).not.toHaveBeenCalled();
    });

    it('should update the results if the state of these results matches the state of the page', function(){
      liveSearch.state = {search: 'state'};
      spyOn(liveSearch.$resultsBlock, 'mustache');
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state));
      expect(liveSearch.$resultsBlock.mustache).toHaveBeenCalled();
    });
  });

  it("should show the filter results button if the GOVUK.support.history returns false", function(){
    // Hide the filter button (this is done in the CSS under the .js-enabled selector normally)
    $form.find('.js-live-search-fallback').hide();
    expect($form.find('.js-live-search-fallback').is(":visible")).toBe(false);
    GOVUK.support.history = function(){ return false; };
    liveSearch = new GOVUK.LiveSearch({$form: $form, $results: $results});
    expect($form.find('.js-live-search-fallback').is(":visible")).toBe(true);
  });

  describe('with relevant DOM nodes set', function(){
    beforeEach(function(){
      liveSearch.$form = $form;
      liveSearch.$resultsBlock = $results;
      liveSearch.$countBlock = $count;
      liveSearch.state = { field: "sheep" };
      liveSearch.$atomAutodiscoveryLink = $atomAutodiscoveryLink;
    });

    it("should update save state and update results when checkbox is changed", function(){
      var promise = jasmine.createSpyObj('promise', ['done']);
      spyOn(liveSearch, 'updateResults').and.returnValue(promise);
      //spyOn(liveSearch, 'pageTrack').and.returnValue(promise);
      $form.find('input').prop('checked', false);

      liveSearch.formChange();
      expect(liveSearch.state).toEqual([]);
      expect(liveSearch.updateResults).toHaveBeenCalled();
      promise.done.calls.mostRecent().args[0]();
      //expect(liveSearch.pageTrack).toHaveBeenCalled();
    });

    it("should trigger analytics trackpage when checkbox is changed", function(){
      var promise = jasmine.createSpyObj('promise', ['done']);
      spyOn(liveSearch, 'updateResults').and.returnValue(promise);
      spyOn(GOVUK.analytics, 'trackPageview');
      liveSearch.state = [];

      liveSearch.formChange();
      promise.done.calls.mostRecent().args[0]();

      expect(GOVUK.analytics.trackPageview).toHaveBeenCalled();
      var trackArgs = GOVUK.analytics.trackPageview.calls.first().args[0];
      expect(trackArgs.split('?')[1], 'field=sheep');
    });

    it("should do nothing if state hasn't changed when a checkbox is changed", function(){
      spyOn(liveSearch, 'updateResults');
      liveSearch.formChange();
      expect(liveSearch.state).toEqual({ field: 'sheep'});
      expect(liveSearch.updateResults).not.toHaveBeenCalled();
    });

    it("should display results from the cache", function(){
      liveSearch.resultCache["the=first"] = dummyResponse;
      liveSearch.state = { the: "first" };
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state));
      expect($results.find('h3').text()).toMatch('Test report');
      expect($count.find('.result-count').text()).toMatch(/^\s*1\s*/);
    });

    it("should update the Atom autodiscovery link", function(){
      liveSearch.displayResults(dummyResponse, $.param(liveSearch.state));
      expect($atomAutodiscoveryLink.attr('href')).toEqual(dummyResponse.atom_url);
    });
  });

  describe("setResultCountTemplate", function(){
    describe("finders with generic descriptions", function(){
      beforeEach(function () {
        $count = $('<div aria-live="assertive" id="js-search-results-info"><p class="result-info" id="generic"></p></div>');
        liveSearch.$countBlock = $count;
      });

      it("should return the generic result count template", function () {
        expect(liveSearch.setResultCountTemplate()).toEqual('_result_count_generic');
      });
    });

    it("should return the default result count template", function(){
      expect(liveSearch.setResultCountTemplate()).toEqual('_result_count');
    });
  });


  describe("popState", function(){
    var dummyHistoryState;

    beforeEach(function(){
      dummyHistoryState = { originalEvent:{ state:true} };
    });

    it("should call restoreBooleans, restoreTextInputs, saveState and updateResults if there is an event in the history", function(){
      spyOn(liveSearch, 'restoreBooleans');
      spyOn(liveSearch, 'restoreTextInputs');
      spyOn(liveSearch, 'saveState');
      spyOn(liveSearch, 'updateResults');

      liveSearch.popState(dummyHistoryState);

      expect(liveSearch.restoreBooleans).toHaveBeenCalled();
      expect(liveSearch.restoreTextInputs).toHaveBeenCalled();
      expect(liveSearch.saveState).toHaveBeenCalled();
      expect(liveSearch.updateResults).toHaveBeenCalled();
    });
  });

  describe("restoreBooleans", function(){
    beforeEach(function(){
      liveSearch.state = [{name:"list_1[]", value:"checkbox_1"}, {name:"list_1[]", value:"checkbox_2"}, {name:'list_2[]', value:"radio_1"}];
      liveSearch.$form = $('<form action="/somewhere" class="js-live-search-form"><input id="check_1" type="checkbox" name="list_1[]" value="checkbox_1"><input type="checkbox" id="check_2"  name="list_1[]" value="checkbox_2"><input type="radio" id="radio_1"  name="list_2[]" value="radio_1"><input type="radio" id="radio_2"  name="list_2[]" value="radio_2"><input type="submit"/></form>');
    });

    it("should check a checkbox if in the state it is checked in the history", function(){
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(0);
      liveSearch.restoreBooleans();
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(2);
    });

    it("should not check all the checkboxes if only one is checked", function(){
      liveSearch.state = [{name:"list_1[]", value:"checkbox_2"}];
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(0);
      liveSearch.restoreBooleans();
      expect(liveSearch.$form.find('input[type=checkbox]:checked')[0].id).toBe('check_2');
      expect(liveSearch.$form.find('input[type=checkbox]:checked').length).toBe(1);
    });

    it("should pick a radiobox if in the state it is picked in the history", function(){
      expect(liveSearch.$form.find('input[type=radio]:checked').length).toBe(0);
      liveSearch.restoreBooleans();
      expect(liveSearch.$form.find('input[type=radio]:checked').length).toBe(1);
    });
  });

  describe("restoreKeywords", function(){
    beforeEach(function(){
       liveSearch.state = [{name:"text_1", value:"Monday"}];
       liveSearch.$form = $('<form action="/somewhere"><input id="text_1" type="text" name="text_1"><input id="text_2" type="text" name="text_2"></form>');
     });

     it("should put the right text back in the right box", function(){
       expect(liveSearch.$form.find('#text_1').val()).toBe('');
       expect(liveSearch.$form.find('#text_2').val()).toBe('');
       liveSearch.restoreTextInputs();
       expect(liveSearch.$form.find('#text_1').val()).toBe('Monday');
       expect(liveSearch.$form.find('#text_2').val()).toBe('');
     });
  });
});
