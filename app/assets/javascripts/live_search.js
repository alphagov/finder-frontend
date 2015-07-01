(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function LiveSearch(options){
    this.state = false;
    this.previousState = false;
    this.resultCache =  {};

    this.$form = options.$form;
    this.$resultsBlock = options.$results.find('#js-results');
    this.$countBlock = options.$results.find('#js-search-results-info');
    this.action = this.$form.attr('action') + '.json';
    this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink;

    if(GOVUK.support.history()){
      this.saveState();
      this.$form.on('change', 'input[type=checkbox], input[type=text], input[type=radio]', this.formChange.bind(this));

      this.$form.find('input[type=text]').keypress(
        function(e){
          if(e.keyCode == 13) {
            // 13 is the return key
            this.formChange();
            e.preventDefault();
          }
        }.bind(this)
      );

      $(window).on('popstate', this.popState.bind(this));
    } else {
      this.$form.find('.js-live-search-fallback').show();
    }
  };

  LiveSearch.prototype.saveState = function saveState(state){
    if(typeof state === 'undefined'){
      state = this.$form.serializeArray();
    }
    this.previousState = this.state;
    this.state = state;
  };

  LiveSearch.prototype.popState = function popState(event){
    if(event.originalEvent.state){
      this.saveState(event.originalEvent.state);
      this.updateResults();
      this.restoreBooleans();
      this.restoreTextInputs();
    }
  };

  LiveSearch.prototype.formChange = function formChange(e){
    var pageUpdated;
    if(this.isNewState()){
      this.saveState();
      pageUpdated = this.updateResults();
      pageUpdated.done(
        function(){
          var newPath = window.location.pathname + "?" + $.param(this.state);
          history.pushState(this.state, '', newPath);
          if (GOVUK.analytics && GOVUK.analytics.trackPageview) {
            GOVUK.analytics.trackPageview(newPath);
          }
        }.bind(this)
      );
    }
  };

  LiveSearch.prototype.cache = function cache(slug, data){
    if(typeof data === 'undefined'){
      return this.resultCache[slug];
    } else {
      this.resultCache[slug] = data;
    }
  };

  LiveSearch.prototype.isNewState = function isNewState(){
    return $.param(this.state) !== this.$form.serialize();
  };

  LiveSearch.prototype.updateResults = function updateResults(){
    var searchState = $.param(this.state);
    var cachedResultData = this.cache(searchState);
    var liveSearch = this;
    if(typeof cachedResultData === 'undefined'){
      this.showLoadingIndicator();
      return $.ajax({
        url: this.action,
        data: this.state,
        searchState: searchState
      }).done(function(response){
        liveSearch.cache($.param(liveSearch.state), response);
        liveSearch.displayResults(response, this.searchState);
      }).error(function(){
        liveSearch.showErrorIndicator();
      });
    } else {
      this.displayResults(cachedResultData, searchState);
      var out = new $.Deferred()
      return out.resolve();
    }
  };

  LiveSearch.prototype.showLoadingIndicator = function showLoadingIndicator(){
    this.$countBlock.text('Loading...');
  };

  LiveSearch.prototype.showErrorIndicator = function showErrorIndicator(){
    this.$countBlock.text('Error. Please try modifying your search and trying again.');
  };

  LiveSearch.prototype.displayResults = function displayResults(results, action){
    // As search is asynchronous, check that the action associated with these results is
    // still the latest to stop results being overwritten by stale data
    if(action == $.param(this.state)) {
      this.$resultsBlock.mustache('finders/_results', results);
      this.$countBlock.mustache('finders/_result_count', results);
      this.$atomAutodiscoveryLink.attr('href', results.atom_url);
    }
  };



  LiveSearch.prototype.restoreBooleans = function restoreBooleans(){
    var that = this;
    this.$form.find('input[type=checkbox], input[type=radio]').each(function(i, el){
      var $el = $(el);
      $el.prop('checked', that.isBooleanSelected($el.attr('name'), $el.attr('value')));
    });
  };

  LiveSearch.prototype.isBooleanSelected = function isBooleanSelected(name, value){
    var i, _i;
    for(i=0,_i=this.state.length; i<_i; i++){
      if(this.state[i].name === name && this.state[i].value === value){
        return true;
      }
    }
    return false;
  };

  LiveSearch.prototype.restoreTextInputs = function restoreTextInputs(){
    var that = this;
    this.$form.find('input[type=text]').each(function(i, el){
      var $el = $(el);
      $el.val(that.getTextInputValue($el.attr('name')));
    });
  };

  LiveSearch.prototype.getTextInputValue = function getTextInputValue(name){
    var i, _i;
    for(i=0,_i=this.state.length; i<_i; i++){
      if(this.state[i].name === name){
        return this.state[i].value
      }
    }
    return '';
  };

  GOVUK.LiveSearch = LiveSearch;
}());
