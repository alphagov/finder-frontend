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
    this.$loadingBlock = options.$results.find('#js-loading-message');
    this.$resultsCount = options.$results.find('#js-result-count');
    this.action = this.$form.attr('action') + '.json';
    this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink;
    this.$emailLink = $('a[href*="email-signup"]');
    this.previousSearchTerm = '';

    this.emailSignupHref = this.$emailLink.attr('href');
    this.$atomLink = $('a[href*=".atom"]');
    this.atomHref = this.$atomLink.attr('href');
    this.$orderSelect = this.$form.find('.js-order-results');
    this.$relevanceOrderOption = this.$orderSelect.find('option[value=' + this.$orderSelect.data('relevance-sort-option') + ']');
    this.$relevanceOrderOptionIndex = this.$relevanceOrderOption.index();

    this.getTaxonomyFacet().update();

    if(GOVUK.support.history()){
      this.saveState();

      this.$form.on('change', 'input[type=checkbox], input[type=radio], select',
        function(e) {
          if (!e.suppressAnalytics) {
            LiveSearch.prototype.fireTextAnalyticsEvent(e);
          }
          this.formChange(e);
        }.bind(this)
      );

      this.$form.on('change keypress', 'input[type=text],input[type=search]',
        function(e){
          var ENTER_KEY = 13;

          if(e.keyCode == ENTER_KEY || e.type == "change") {
            if (e.currentTarget.value != this.previousSearchTerm) {
              if (!e.suppressAnalytics) {
                LiveSearch.prototype.fireTextAnalyticsEvent(e);
              }
            }
            this.formChange(e);
            this.previousSearchTerm = e.currentTarget.value;
            e.preventDefault();
          }
        }.bind(this)
      );

      this.indexTrackingData();

      $(window).on('popstate', this.popState.bind(this));
    } else {
      this.$form.find('.js-live-search-fallback').show();
    }
  }

  LiveSearch.prototype.getTaxonomyFacet = function getTaxonomyFacet() {
    this.taxonomy = this.taxonomy || new GOVUK.TaxonomySelect({ $el: $('.app-taxonomy-select') });
    return this.taxonomy;
  };

  LiveSearch.prototype.getSerializeForm = function getSerializeForm(){
    var uncleanState = this.$form.serializeArray();
    return uncleanState.filter(function(field){ return field.name !== 'option-select-filter'; });
  };

  LiveSearch.prototype.saveState = function saveState(state){
    if(typeof state === 'undefined'){
      state = this.getSerializeForm();
    }
    this.previousState = this.state;
    this.state = state;
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
      this.updateLinks();
      pageUpdated = this.updateResults();
      pageUpdated.done(
        function(){
          var newPath = window.location.pathname + "?" + $.param(this.state);
          history.pushState(this.state, '', newPath);
          this.trackingInit();
          this.trackPageView();
        }.bind(this)
      );
    }
  };

  LiveSearch.prototype.trackingInit = function() {
    GOVUK.modules.start($('.js-live-search-results-block'));
    this.indexTrackingData();
  };

  LiveSearch.prototype.trackPageView = function trackPageView() {
    if (this.canTrackPageview()) {
      var newPath = window.location.pathname + "?" + $.param(this.state);
      GOVUK.analytics.trackPageview(newPath);
    }
  };

  /**
   * Results grouped by facet and facet value do not have an accurate document index
   * due to the post-search sorting and grouping which the presenter performs.
   * In this case (ie. sorted by 'Topic' which actually means group by facet, facet value),
   * rewrite the appropriate tracking data attribute to delineate the group and document index
   * and also whether the document is promoted to the top of the group.
   * eg. data-track-action='Some magic finder.0.1p' is the 2nd pinned document in the first group.
   */
  LiveSearch.prototype.indexTrackingData = function indexTrackingData() {
    var $groupEls = $('.filtered-results__group');
    if ($groupEls.length > 0) {
      $groupEls.each(function(groupIndex) {
        var $resultEls = $(this).find('.document');
        $resultEls.each(function(documentIndex) {
          var $document = $(this);
          var $documentLink = $document.find('a');
          var trackingAction = $documentLink.attr('data-track-action');
          trackingAction = trackingAction.replace(/\.\d+$/,"");
          trackingAction = [trackingAction, groupIndex + 1, documentIndex + 1].join(".");
          if ($document.find('.document-heading--pinned').length == 1) {
            trackingAction += 'p';
          }
          $documentLink.attr('data-track-action', trackingAction);
        });
      });
    }
  };

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
  };

  LiveSearch.prototype.canTrackPageview = function() {
    return GOVUK.analytics && GOVUK.analytics.trackPageview;
  };

  LiveSearch.prototype.cache = function cache(slug, data){
    if(typeof data === 'undefined'){
      return this.resultCache[slug];
    } else {
      this.resultCache[slug] = data;
    }
  };

  LiveSearch.prototype.isNewState = function isNewState(){
    return $.param(this.state) !== $.param(this.getSerializeForm());
  };

  LiveSearch.prototype.updateOrder = function updateOrder() {
    if (!this.$orderSelect.length) {
      return;
    }

    var liveSearch = this;
    var keywords = this.getTextInputValue('keywords', this.state);
    var previousKeywords = this.getTextInputValue('keywords', this.previousState);

    var keywordsPresent = keywords !== "";
    var previousKeywordsPresent = previousKeywords !== "";
    var keywordsCleared = !keywordsPresent && previousKeywordsPresent;

    if (keywordsPresent) {
      liveSearch.insertRelevanceOption();
      if(!previousKeywordsPresent){
        liveSearch.selectRelevanceSortOption();
      }
    } else {
      liveSearch.removeRelevanceOption();
    }

    if (keywordsCleared) {
      liveSearch.selectDefaultSortOption();
    }
  };

  LiveSearch.prototype.selectDefaultSortOption = function selectDefaultSortOption() {
    var defaultSortOption = this.$orderSelect.data('default-sort-option');

    this.$orderSelect.val(defaultSortOption);
    this.state = this.getSerializeForm();
  };

  LiveSearch.prototype.selectRelevanceSortOption = function selectRelevanceSortOption() {
    var relevanceSortOption = this.$orderSelect.data('relevance-sort-option');

    if (relevanceSortOption) {
      this.$orderSelect.val(relevanceSortOption);
      this.state = this.getSerializeForm();
    }
  };

  LiveSearch.prototype.insertRelevanceOption = function insertRelevanceOption() {
    var adjacentOption = this.$orderSelect.children("option").eq(this.$relevanceOrderOptionIndex);
    this.$relevanceOrderOption.removeAttr('disabled');
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
      var out = new $.Deferred();
      return out.resolve();
    }
  };

  LiveSearch.prototype.updateLinks = function updateLinks() {
    var searchState = "?" + $.param(this.state);
    if (typeof(this.emailSignupHref)!='undefined' && this.emailSignupHref!=null) {
      this.$emailLink.attr('href', this.emailSignupHref.split('?')[0] + searchState);
    }
    if (typeof(this.atomHref)!='undefined' && this.atomHref!=null) {
      this.$atomLink.attr('href', this.atomHref.split('?')[0] + searchState);
      this.$atomAutodiscoveryLink.attr('href', this.atomHref.split('?')[0] + searchState);
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
      this.$countBlock.mustache(this.templateDir + '_result_count', results);
      this.$resultsCount.text(results.total + " " + results.pluralised_document_noun);
      this.$atomAutodiscoveryLink.attr('href', results.atom_url);
      this.$loadingBlock.text('').hide();
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
    this.$form.find('input[type=text], input[type=search], select').each(function(i, el){
      var $el = $(el);
      $el.val(that.getTextInputValue($el.attr('name'), that.state));
    });
  };

  LiveSearch.prototype.getTextInputValue = function getTextInputValue(name, state){
    var i, _i;
    for(i=0,_i=state.length; i<_i; i++){
      if(state[i].name === name){
        return state[i].value;
      }
    }
    return '';
  };

  GOVUK.LiveSearch = LiveSearch;
}());
