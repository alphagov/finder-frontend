describe("liveSiteSearch", function(){
  var $form, $results, _supportHistory;
  var dummyResponse = {
    "query":"fiddle",
    "result_count_string":"1 result",
    "result_count":1,
    "results_any?":true,
    "results":[
      {"title_with_highlighting":"my-title","link":"my-link","description":"my-description"}
    ]
  };

  beforeEach(function () {
    $form = $('<form action="/somewhere" class="js-live-search-form"><input type="checkbox" name="field" value="sheep" checked></form>');
    $results = $('<div class="js-live-search-results-block"><div class="result-count"></div><div class="js-live-search-results-list">my result list</div></div>');
    $arialivetext = $('<div class="js-aria-live-count">10 results</div>');
    $('body').append($form).append($results).append($arialivetext);

    _supportHistory = GOVUK.support.history;
    GOVUK.support.history = function(){ return true; };
    GOVUK.liveSiteSearch.resultCache = {};
  });

  afterEach(function(){
    $form.remove();
    $results.remove();
    $arialivetext.remove();
    GOVUK.support.history = _supportHistory;
  });

  it("should save initial state", function(){
    GOVUK.liveSiteSearch.init();
    expect(GOVUK.liveSiteSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
  });

  it("should detect a new state", function(){
    GOVUK.liveSiteSearch.init();
    expect(GOVUK.liveSiteSearch.isNewState()).toBe(false);
    $form.find('input').prop('checked', false);
    expect(GOVUK.liveSiteSearch.isNewState()).toBe(true);
  });

  it("should update state to current state", function(){
    GOVUK.liveSiteSearch.init();
    expect(GOVUK.liveSiteSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    GOVUK.liveSiteSearch.saveState();
    expect(GOVUK.liveSiteSearch.state).toEqual([]);
  });

  it("should update state to passed in state", function(){
    GOVUK.liveSiteSearch.init();
    expect(GOVUK.liveSiteSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    GOVUK.liveSiteSearch.saveState({ my: "new", state: "object"});
    expect(GOVUK.liveSiteSearch.state).toEqual({ my: "new", state: "object"});
  });

  it("should not request new results if they are in the cache", function(){
    GOVUK.liveSiteSearch.resultCache["more=results"] = "exists";
    GOVUK.liveSiteSearch.state = { more: "results" };
    spyOn(GOVUK.liveSiteSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    GOVUK.liveSiteSearch.updateResults();
    expect(GOVUK.liveSiteSearch.displayResults).toHaveBeenCalled();
    expect(jQuery.ajax).not.toHaveBeenCalled();
  });

  it("should return a promise like object if results are in the cache", function(){
    GOVUK.liveSiteSearch.resultCache["more=results"] = "exists";
    GOVUK.liveSiteSearch.state = { more: "results" };
    spyOn(GOVUK.liveSiteSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    var promise = GOVUK.liveSiteSearch.updateResults();
    expect(typeof promise.done).toBe('function');
  });

  it("should return a promise like object if results aren't in the cache", function(){
    GOVUK.liveSiteSearch.state = { not: "cached" };
    spyOn(GOVUK.liveSiteSearch, 'displayResults');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    GOVUK.liveSiteSearch.updateResults();
    expect(jQuery.ajax).toHaveBeenCalledWith({url: '/somewhere.json', data: {not: "cached"}});
    expect(ajaxCallback.done).toHaveBeenCalled();
    ajaxCallback.done.calls.mostRecent().args[0]('response data'); // call the function passed to the promise
    expect(GOVUK.liveSiteSearch.displayResults).toHaveBeenCalled();
    expect(GOVUK.liveSiteSearch.resultCache['not=cached']).toBe('response data');
  });

  it("should show and hide loading indicator when loading new results", function(){
    GOVUK.liveSiteSearch.state = { not: "cached" };
    spyOn(GOVUK.liveSiteSearch, 'displayResults');
    spyOn(GOVUK.liveSiteSearch, 'showLoadingIndicator');
    spyOn(GOVUK.liveSiteSearch, 'hideLoadingIndicator');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    GOVUK.liveSiteSearch.updateResults();
    expect(GOVUK.liveSiteSearch.showLoadingIndicator).toHaveBeenCalled();
    ajaxCallback.done.calls.mostRecent().args[0]('response data');
    expect(GOVUK.liveSiteSearch.hideLoadingIndicator).toHaveBeenCalled();
  });

  it("should show error indicator when error loading new results", function(){
    GOVUK.liveSiteSearch.state = { not: "cached" };
    spyOn(GOVUK.liveSiteSearch, 'displayResults');
    spyOn(GOVUK.liveSiteSearch, 'showErrorIndicator');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    GOVUK.liveSiteSearch.updateResults();
    ajaxCallback.error.calls.mostRecent().args[0]();
    expect(GOVUK.liveSiteSearch.showErrorIndicator).toHaveBeenCalled();
  });

  it("should return cache items for current state", function(){
    GOVUK.liveSiteSearch.state = { not: "cached" };
    expect(GOVUK.liveSiteSearch.cache()).toBe(undefined);
    GOVUK.liveSiteSearch.cache('something in the cache');
    expect(GOVUK.liveSiteSearch.cache()).toBe('something in the cache');
  });

  it("should return the search term from a state object", function(){
    var state = [{ name: "q", value: "my-search-term" }, { name: "other", value: "something" }];

    expect(GOVUK.liveSiteSearch.searchTermValue(state)).toBe('my-search-term');
    expect(GOVUK.liveSiteSearch.searchTermValue(false)).toBe(false);
    expect(GOVUK.liveSiteSearch.searchTermValue(null)).toBe(false);
  });

  it("should only allow 15 organisations to be selected", function(){
    var orgList = [];
    for(var i=0;i<15;i++){ orgList.push( { name: 'filter_organisations[]' } ); }
    spyOn(GOVUK.liveSiteSearch.$form, 'serializeArray').and.returnValue(orgList);
    spyOn(window, 'alert');
    var event = jasmine.createSpyObj('event', ['preventDefault']);
    expect(GOVUK.liveSiteSearch.checkFilterLimit(event)).toBe(true);

    orgList.push( { name: 'filter_organisations[]' } );
    expect(GOVUK.liveSiteSearch.checkFilterLimit(event)).toBe(false);
  });

  it("should only allow 15 filters in total to be selected", function(){
    var orgList = [];
    for(var i=0;i<15;i++){ orgList.push( { name: 'filter_organisations[]' } ); }
    spyOn(GOVUK.liveSiteSearch.$form, 'serializeArray').and.returnValue(orgList);
    spyOn(window, 'alert');
    var event = jasmine.createSpyObj('event', ['preventDefault']);
    expect(GOVUK.liveSiteSearch.checkFilterLimit(event)).toBe(true);

    orgList.push( { name: 'filter_organisations[]' } );
    expect(GOVUK.liveSiteSearch.checkFilterLimit(event)).toBe(false);
  });

  describe('with relevant dom nodes set', function(){
    beforeEach(function(){
      GOVUK.liveSiteSearch.$form = $form;
      GOVUK.liveSiteSearch.$resultsBlock = $results;
      GOVUK.liveSiteSearch.state = { field: "sheep" };
    });

    it("should update save state and update results when checkbox is changed", function(){
      var promise = jasmine.createSpyObj('promise', ['done']);
      spyOn(GOVUK.liveSiteSearch, 'updateResults').and.returnValue(promise);
      spyOn(GOVUK.liveSiteSearch, 'pageTrack').and.returnValue(promise);
      $form.find('input').prop('checked', false);

      GOVUK.liveSiteSearch.checkboxChange();
      expect(GOVUK.liveSiteSearch.state).toEqual([]);
      expect(GOVUK.liveSiteSearch.updateResults).toHaveBeenCalled();
      promise.done.calls.mostRecent().args[0]();
      expect(GOVUK.liveSiteSearch.pageTrack).toHaveBeenCalled();
    });

    it("should do nothing if state hasn't changed when a checkbox is changed", function(){
      spyOn(GOVUK.liveSiteSearch, 'updateResults');
      GOVUK.liveSiteSearch.checkboxChange();
      expect(GOVUK.liveSiteSearch.state).toEqual({ field: 'sheep'});
      expect(GOVUK.liveSiteSearch.updateResults).not.toHaveBeenCalled();
    });

    it("should display results from the cache", function(){
      GOVUK.liveSiteSearch.resultCache["the=first"] = dummyResponse;
      GOVUK.liveSiteSearch.state = { the: "first" };
      GOVUK.liveSiteSearch.displayResults();

      expect($results.find('h3').text()).toBe('my-title');
      expect($results.find('#js-live-search-result-count').text()).toMatch(/^\s+1 result/);
    });

    it("should restore checkbox values", function(){
      GOVUK.liveSiteSearch.state = [ { name: "field", value: "sheep" } ];
      GOVUK.liveSiteSearch.restoreCheckboxes();
      expect($form.find('input').prop('checked')).toBe(true);

      GOVUK.liveSiteSearch.state = [ ];
      GOVUK.liveSiteSearch.restoreCheckboxes();
      expect($form.find('input').prop('checked')).toBe(false);
    });

    it ("display results should call updateAriaLiveCount when the results have been loaded", function(){
      spyOn(GOVUK.liveSiteSearch, 'updateAriaLiveCount');

      GOVUK.liveSiteSearch.displayResults();
      expect(GOVUK.liveSiteSearch.updateAriaLiveCount).toHaveBeenCalled();

    });

    it ("updateAriaLiveCount should change the text of the aria-live region to match the result count", function(){
      var oldCount = '1 search result',
          newCount = '70 search results';

      GOVUK.liveSiteSearch.$resultsBlock.find('.result-count').text(newCount);
      GOVUK.liveSiteSearch.updateAriaLiveCount();
      expect(GOVUK.liveSiteSearch.$ariaLiveResultCount.text()).toBe(newCount);
    });
  });
});
