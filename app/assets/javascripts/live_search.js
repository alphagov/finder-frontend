(function() {
  "use strict";

  window.GOVUK = window.GOVUK || {};

  function LiveSearch(options){
    this.state = false;
    this.previousState = false;
    this.resultCache =  {};
    this.templateDir = options.templateDir || 'finders/';
    this.questionData = false;
    this.questionIndex = false;

    this.$form = options.$form;
    this.$resultsBlock = options.$results.find('#js-results');
    this.$countBlock = options.$results.find('#js-search-results-info');
    this.$loadingBlock = options.$results.find('#js-loading-message');
    this.$resultsCount = options.$results.find('#js-result-count');
    this.action = this.$form.attr('action') + '.json';
    this.$atomAutodiscoveryLink = options.$atomAutodiscoveryLink;
    this.$emailLink = $("p.email-link a");

    this.emailSignupHref = this.$emailLink.attr('href');

    this.$orderSelectWrapper = this.$form.find('.js-sort-button-wrapper');
    this.$orderSelect = this.$form.find('.js-order-results');
    this.$keywordSearch = $('#finder-keyword-search');
    this.$keywordResults = $('.js-question-results');
    this.$relevanceOrderOption = this.$orderSelect.find('option[value=' + this.$orderSelect.data('relevance-sort-option') + ']');
    this.$relevanceOrderOptionIndex = this.$relevanceOrderOption.index();

    this.getTaxonomyFacet().update();

    if(GOVUK.support.history()){
      this.saveState();

      this.$form.on('change', 'input[type=checkbox], input[type=text], input[type=search], input[type=radio], select',
        function(e) {
          if (e.target.type == "text" && !e.suppressAnalytics) {
            LiveSearch.prototype.fireTextAnalyticsEvent(e);
          }
          this.formChange(e)
        }.bind(this)
      );

      this.$form.on('keypress', 'input[type=search]', 'input[type=text]',
        function(e){
          var ENTER_KEY = 13

          if(e.keyCode == ENTER_KEY) {
            this.formChange(e);
            e.preventDefault();
          }
        }.bind(this)
      );

      this.$form.find('.js-finder-search-submit').on('click', function(e) {
        e.preventDefault();
        this.formChange(e);
      });

      this.updateOrder();
      this.indexTrackingData();

      $(window).on('popstate', this.popState.bind(this));
    } else {
      this.$form.find('.js-live-search-fallback').show();
    }

    this.loadQuestionData();
    this.setupSearch();
  };

  LiveSearch.prototype.loadQuestionData = function () {
    var questionData = JSON.parse($('#faq-questions').text());

    this.questionIndex = lunr(function () {
      this.ref('id');
      this.field('question');

      // Remove stemmer
      this.pipeline.remove(lunr.stemmer)
      this.searchPipeline.remove(lunr.stemmer)

      // Alias this as this is refined inside $.each
      var searchIndex = this;

      $.each(questionData, function (id, question) {
        searchIndex.add({
          id: id,
          question: question.question
        });
      });
    });

    this.questionData = questionData;
  };

  LiveSearch.prototype.setupSearch = function () {
    var that = this;
    this.$keywordSearch.on('input', function () {
      var searchTerms = $(this).val();

      that.$keywordResults.empty();

      if (searchTerms.length < 3) {
        return;
      }

      var searchResults = that.search(searchTerms);

      $.each(searchResults, function(_, result) {
        that.$keywordResults.append(
            $('<li>')
              .text(result.question)
              .data({ id: result.id })
        );
      });
    });

    this.$keywordResults.on('click', 'li', function () {
      that.showQuestion($(this).data('id'));
      that.$keywordSearch.val($(this).text()).trigger('change');
    })
  };

  LiveSearch.prototype.showQuestion = function (id) {
    var questionData = this.getResult(id);
    var question = $('<div class="faq">');

    $('.faq').remove();

    question.append($('<p class="faq__question">').text(questionData.question));

    question.append($('<a class="faq__link">').text(questionData.title).attr('href', questionData.link));
    question.append($('<p class="faq_description">').text(questionData.description));

    this.$resultsBlock.before(question)
  }

  LiveSearch.prototype.search = function (keywords) {
    var results = this.questionIndex.query(function (q) {
      const tokens = lunr.tokenizer(keywords);
      const last = tokens.pop();

      if (tokens.length > 1) {
        q.term(tokens);
      }

      q.term(last, {
        wildcard: lunr.Query.wildcard.TRAILING
      });
    });

    var that = this;

    return $.map(results, function(result) {
      return $.extend(
          that.getResult(result.ref),
          { id: result.ref }
      )
    });
  }

  LiveSearch.prototype.getResult = function (id) {
    return this.questionData[id];
  }

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

    if (this.emailSignupHref) {
      this.$emailLink.attr(
        'href', this.emailSignupHref.split('?')[0] + "?" + $.param(this.state)
      );
    }
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
          this.trackPageView();
        }.bind(this)
      )
    }
  };

  LiveSearch.prototype.trackingInit = function() {
    GOVUK.modules.start($('.js-live-search-results-block'));
    this.indexTrackingData();
  }

  LiveSearch.prototype.trackPageView = function trackPageView() {
    if (this.canTrackPageview()) {
      var newPath = window.location.pathname + "?" + $.param(this.state);
      GOVUK.analytics.trackPageview(newPath);
    }
  }

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
        })
      })
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
  };

  LiveSearch.prototype.selectDefaultSortOption = function selectDefaultSortOption() {
    var defaultSortOption = this.$orderSelect.data('default-sort-option');

    this.$orderSelect.val(defaultSortOption);
    this.state = this.$form.serializeArray();
  };

  LiveSearch.prototype.selectRelevanceSortOption = function selectRelevanceSortOption() {
    var relevanceSortOption = this.$orderSelect.data('relevance-sort-option');

    if (relevanceSortOption) {
      this.$orderSelect.val(relevanceSortOption);
      this.state = this.$form.serializeArray();
    }
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
      this.$orderSelectWrapper.toggleClass("js-hidden", !!this.getTextInputValue("keywords", this.state));
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
        return state[i].value
      }
    }
    return '';
  };

  GOVUK.LiveSearch = LiveSearch;
}());
