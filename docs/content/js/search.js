(function () {
  'use strict';

  var idx = null;
  var documents = null;
  var searchInput, searchResults;
  var scriptEl = document.querySelector('script[src$="/js/search.js"]');
  var baseUrl = scriptEl ? scriptEl.src.replace(/js\/search\.js$/, '') : '/';

  function init() {
    if (typeof lunr === 'undefined') {
      // lunr not loaded yet, retry
      setTimeout(init, 100);
      return;
    }
    searchInput = document.getElementById('search-input');
    searchResults = document.getElementById('search-results');
    if (!searchInput || !searchResults) return;
    bindEvents();
  }

  // Load the pre-built search index
  function loadIndex() {
    if (idx) return Promise.resolve();
    return fetch(baseUrl + 'search-index.json')
      .then(function (res) { return res.json(); })
      .then(function (data) {
        documents = data.documents;
        idx = lunr.Index.load(data.index);
      })
      .catch(function (err) {
        console.error('Failed to load search index:', err);
      });
  }

  function performSearch(query) {
    if (!idx || !query || query.length < 2) {
      searchResults.style.display = 'none';
      searchResults.innerHTML = '';
      return;
    }

    var results;
    try {
      results = idx.search(query + '*');
    } catch (e) {
      results = idx.search(query);
    }

    if (results.length === 0) {
      searchResults.innerHTML = '<div class="search-no-results">No results found</div>';
      searchResults.style.display = 'block';
      return;
    }

    var html = results.slice(0, 8).map(function (result) {
      var doc = documents[result.ref];
      return '<a class="search-result-item" href="' + baseUrl + doc.url + '">' +
        '<span class="search-result-title">' + doc.title + '</span>' +
        (doc.snippet ? '<span class="search-result-snippet">' + doc.snippet + '</span>' : '') +
        '</a>';
    }).join('');

    searchResults.innerHTML = html;
    searchResults.style.display = 'block';
  }

  // Event listeners
  function bindEvents() {
    var debounceTimer;
    searchInput.addEventListener('focus', function () {
      loadIndex();
    });

    searchInput.addEventListener('input', function () {
      clearTimeout(debounceTimer);
      var query = searchInput.value.trim();
      debounceTimer = setTimeout(function () {
        loadIndex().then(function () {
          performSearch(query);
        });
      }, 200);
    });

    // Close results when clicking outside
    document.addEventListener('click', function (e) {
      if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
        searchResults.style.display = 'none';
      }
    });

    // Reshow results on focus if there's a query
    searchInput.addEventListener('focus', function () {
      if (searchInput.value.trim().length >= 2) {
        loadIndex().then(function () {
          performSearch(searchInput.value.trim());
        });
      }
    });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
