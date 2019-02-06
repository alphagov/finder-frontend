(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function LiveSearch(options){
    this.state = false;
    this.previousState = false;
    this.resultCache =  {};
    this.templateDir = options.templateDir || 'finders/';

    this.$form = options.$form;
    this.$resultsBlock = options.$results.find('#js-results');
    this.$countBlock = options.$results.find('#js-search-results-info');
    this.$loadingBlock = options.$results.find('#live-search-loading-message');
    this.$resultsCount = options.$results.find('#result-count');
    this.action = this.$form.attr('action') + '.json';
    this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink;
    this.$emailLink = $("p.email-link a");

    this.emailSignupHref = this.$emailLink.attr('href');

    this.$orderSelect = this.$form.find('.js-order-results');
    this.$relevanceOrderOption = this.$orderSelect.find('option[value=' + this.$orderSelect.data('relevance-sort-option') + ']');
    this.$relevanceOrderOptionIndex = this.$relevanceOrderOption.index();

    this.resultCountTemplate = this.setResultCountTemplate();
    this.getTaxonomyFacet().update();

    if(GOVUK.support.history()){
      this.saveState();

      this.$form.find('input[type=checkbox], input[type=text], input[type=search], input[type=radio], select').on('change',
        function(e) {
          if (e.target.type == "text") {
            LiveSearch.prototype.fireTextAnalyticsEvent(e);
          }
          if (e.target.type == "search") {
            if (!e.target.value.trim()) {
              $('.js-search-clear').addClass("js-hidden");
            } else {
              $('.js-search-clear').removeClass("js-hidden");
            }
            LiveSearch.prototype.fireTextAnalyticsEvent(e);
          }
          this.formChange(e)
        }.bind(this)
      );

      this.$form.find('.js-search-clear').on('click', function(e) {
        e.preventDefault();
        $('.business-finder-search input[type=search]').val("").trigger('change');
      });

      this.$form.find('.js-finder-search-submit').on('click', function(e) {
        e.preventDefault();
        this.formChange(e);
      });

      this.$form.find('input[type=text], input[type=search]').on('keypress',
        function(e){
          var ENTER_KEY = 13

          if(e.keyCode == ENTER_KEY) {
            this.formChange(e);
            e.preventDefault();
          }
        }.bind(this)
      );

      this.updateOrder();

      $(window).on('popstate', this.popState.bind(this));
    } else {
      this.$form.find('.js-live-search-fallback').show();
    }
  };

  LiveSearch.prototype.setResultCountTemplate = function setResultCountTemplate(){
    if (this.$countBlock.find('#generic').length == 1){
      return '_result_count_generic';
    } else {
      return '_result_count';
    }
  };

  LiveSearch.prototype.getTaxonomyFacet = function getTaxonomyFacet() {
    this.taxonomy = this.taxonomy || new GOVUK.TaxonomySelect({ $el: $('.app-taxonomy-select') });
    return this.taxonomy;
  }

  LiveSearch.prototype.saveState = function saveState(state){
    if(typeof state === 'undefined'){
      state = this.$form.serializeArray();
    }
    this.previousState = this.state;
    this.state = state;

    this.$emailLink.attr(
      'href', this.emailSignupHref + "?" + $.param(this.state)
    );
  };

  LiveSearch.prototype.popState = function popState(event){
    if(event.originalEvent.state){
      this.saveState(event.originalEvent.state);
      this.updateOrder();
      this.updateResults();
      this.restoreBooleans();
      this.restoreTextInputs();
    }
  };

  LiveSearch.prototype.formChange = function formChange(e){
    var pageUpdated;
    if(this.isNewState()){
      this.getTaxonomyFacet().update();
      this.saveState();
      this.updateOrder();
      pageUpdated = this.updateResults();
      pageUpdated.done(
        function(){
          var newPath = window.location.pathname + "?" + $.param(this.state);
          history.pushState(this.state, '', newPath);
          this.trackingInit();
        }.bind(this)
      )
    }
    this.trackPageView();
  };

  LiveSearch.prototype.trackingInit = function() {
    GOVUK.modules.start($('.js-live-search-results-block'));
  }

  LiveSearch.prototype.trackPageView = function trackPageView() {
    if (this.canTrackPageview()) {
      var newPath = window.location.pathname + "?" + $.param(this.state);
      GOVUK.analytics.trackPageview(newPath);
    }
  }

  LiveSearch.prototype.fireTextAnalyticsEvent = function(event) {
    if (this.canTrackPageview()) {
      var options = {
        transport: 'beacon',
        label: $(event.target)[0].value
      };
      var category = "filterClicked";
      var action = $('label[for="' + event.target.id + '"]')[0].innerText;

      GOVUK.analytics.trackEvent(
        category,
        action,
        options
      );
    }
  }

  LiveSearch.prototype.canTrackPageview = function() {
    return GOVUK.analytics && GOVUK.analytics.trackPageview;
  }

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

  LiveSearch.prototype.updateOrder = function updateOrder() {
    if (!this.$orderSelect.length) {
      return
    }

    var liveSearch = this;

    var keywords = this.getTextInputValue('keywords', this.state);
    var previousKeywords = this.getTextInputValue('keywords', this.previousState);

    var keywordsPresent = keywords !== "";
    var keywordsBlank = !keywordsPresent;

    var previousKeywordsPresent = previousKeywords !== "";
    var previousKeywordsBlank = !previousKeywordsPresent;

    var keywordsChanged = keywordsPresent && (previousKeywordsBlank || (keywords !== previousKeywords));
    var keywordsCleared = keywordsBlank && previousKeywordsPresent;

    if (keywordsPresent) {
      liveSearch.insertRelevanceOption();
    } else {
      liveSearch.removeRelevanceOption();
    }

    if (keywordsCleared) {
      liveSearch.selectDefaultSortOption();
    }

    if (keywordsChanged) {
      liveSearch.selectRelevanceSortOption();
    }

    LiveSearch.prototype.displayAnswerBox(this.state)
  };

  LiveSearch.prototype.selectDefaultSortOption = function selectDefaultSortOption() {
    var defaultSortOption = this.$orderSelect.data('default-sort-option');

    this.$orderSelect.val(defaultSortOption);
    this.state = this.$form.serializeArray();
  };

  LiveSearch.prototype.selectRelevanceSortOption = function selectRelevanceSortOption() {
    var relevanceSortOption = this.$orderSelect.data('relevance-sort-option');

    this.$orderSelect.val(relevanceSortOption);
    this.state = this.$form.serializeArray();
  };

  LiveSearch.prototype.insertRelevanceOption = function insertRelevanceOption() {
    var adjacentOption = this.$orderSelect.children("option").eq(this.$relevanceOrderOptionIndex);

    adjacentOption.before(this.$relevanceOrderOption);
  };

  LiveSearch.prototype.removeRelevanceOption = function removeRelevanceOption() {
    this.$relevanceOrderOption.removeAttr('disabled');
    this.$relevanceOrderOption.remove();
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
    this.$loadingBlock.text('Loading...').show();
  };

  LiveSearch.prototype.showErrorIndicator = function showErrorIndicator(){
    this.$loadingBlock.text('Error. Please try modifying your search and trying again.');
  };

  LiveSearch.prototype.displayResults = function displayResults(results, action){
    // As search is asynchronous, check that the action associated with these results is
    // still the latest to stop results being overwritten by stale data
    if(action == $.param(this.state)) {
      this.$resultsBlock.mustache(this.templateDir + '_results', results);
      //this.$countBlock.mustache(this.templateDir + this.resultCountTemplate, results);
      this.$resultsCount.text(results.total + " " + results.pluralised_document_noun);
      this.$atomAutodiscoveryLink.attr('href', results.atom_url);
      this.$loadingBlock.text('').hide();
    }

    LiveSearch.prototype.displayAnswerBox(this.state)
  };

  // Display a predefined answer box when users search for specific keywords
  LiveSearch.prototype.displayAnswerBox = function (state) {
    // Get user's query (string of keywords)
    var keywords = this.getTextInputValue('keywords', state).toLowerCase()

    // Prefedine a list of  keywords
    var predefinedKeywordsForPrototype = ['driving licence', 'drive', 'driving', 'licence']

    // Look for each predefined keyword to see if any of them are listed in the query
    var keywordsMatch = false
    predefinedKeywordsForPrototype.forEach(function (keyword) {
      if (keywords.indexOf(keyword) >= 0) keywordsMatch = true
    })

    // If we have matches displat the first answer box
    if (keywordsMatch) {
      var element = document.querySelector('.document--answer')
      if (element) {
        element.style.display = 'block'
      }
    }
  }

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
    this.$form.find('input[type=text], input[type=search], select').each(function(i, el){
      var $el = $(el);
      $el.val(that.getTextInputValue($el.attr('name'), that.state));
    });
  };

  LiveSearch.prototype.getTextInputValue = function getTextInputValue(name, state){
    var i, _i;
    for(i=0,_i=state.length; i<_i; i++){
      if(state[i].name === name){
        return state[i].value
      }
    }
    return '';
  };

  GOVUK.LiveSearch = LiveSearch;
}());
