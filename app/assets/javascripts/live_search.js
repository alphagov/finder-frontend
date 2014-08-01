(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function LiveSearch(options){
    this.action = false;
    this.state = false;
    this.previousState = false;
    this.resultCache =  {};

    this.$form = options.$form;
    this.$resultsBlock = options.$results;
    this.action = this.$form.attr('action') + '.json';

    if(GOVUK.support.history()){
      this.saveState();
      this.$form.on('change', 'input[type=checkbox], input[type=text]', $.proxy(this.formChange, this));

      $(window).on('popstate', $.proxy(this.popState, this));
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
      this.restoreCheckboxes();
    }
  };

  LiveSearch.prototype.formChange = function formChange(e){
    var pageUpdated;
    if(this.isNewState()){
      this.saveState();
      pageUpdated = this.updateResults();
      pageUpdated.done(
        $.proxy(
          function(){
            history.pushState(this.state, '', window.location.pathname + "?" + $.param(this.state));
          },
          this)
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
    var cachedResultData = this.cache($.param(this.state));
    var liveSearch = this;
    if(typeof cachedResultData === 'undefined'){
      $.proxy(this.showLoadingIndicator, this);
      return $.ajax({
        url: this.action,
        data: this.state
      }).done(function(response){
        liveSearch.cache($.param(liveSearch.state), response);
        liveSearch.displayResults(response);
      }).error(function(){
        liveSearch.showErrorIndicator();
      });
    } else {
      this.displayResults(cachedResultData);
      var out = new $.Deferred()
      return out.resolve();
    }
  };

  LiveSearch.prototype.showLoadingIndicator = function showLoadingIndicator(){
    var $resultCount = this.$results.find('.result-info');
    $resultCount.text('Loading...');
  };

  LiveSearch.prototype.showErrorIndicator = function showErrorIndicator(){
    this.$resultsBlock.find('.result-info').text('Error. Please try modifying your search and trying again.');
  };

  LiveSearch.prototype.displayResults = function displayResults(results){
    this.$resultsBlock.mustache('finders/_results', results);
  };

  LiveSearch.prototype.restoreCheckboxes = function restoreCheckboxes(){
    var that = this;
    this.$form.find('input[type=checkbox]').each(function(i, el){
      var $el = $(el);
      $el.prop('checked', that.isCheckboxSelected($el.attr('name'), $el.attr('value')));
    });
  };

  LiveSearch.prototype.isCheckboxSelected = function isCheckboxSelected(name, value){
    var i, _i;
    for(i=0,_i=this.state.length; i<_i; i++){
      if(this.state[i].name === name && this.state[i].value === value){
        return true;
      }
    }
    return false;
  };

  GOVUK.LiveSearch = LiveSearch;
}());
