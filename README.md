#Finder Frontend

##Purpose
![Finder frontend screenshot](https://raw.githubusercontent.com/alphagov/finder-frontend/master/docs/assets/page-screenshot.png)

Faceted searching over documents.

##Nomenclature
* Finder: Page containing a list of filterable documents and filters.
* Facets: Searchable/filterable metadata for example `case_state={open|closed}` for a CMA case.

##Current finders
* [gov.uk/cma-cases](http://gov.uk/cma-cases)
* [gov.uk/international-development-funding](http://gov.uk/international-development-funding)

##Dependencies
* [alphagov/static](http://github.com/alphagov/static): provides static assets (JS/CSS) and provides the GOV.UK templates.
* [alphagov/finder-api](http://github.com/alphagov/finder-api): provides the schema used to build the list of facets
* [alphagov/content-store](http://github.com/alphagov/content-store): provides the content items for the finder itself -- containing the finder title, tagged organisations and related links
* [alphagov/rummager](http://github.com/alphagov/rummager): provides search results

##Running the application

```
$ ./startup.sh
```

If you are using the GDS development virtual machine then the application will be available on the host at [http://finder-frontend.dev.gov.uk/](http://finder-frontend.dev.gov.uk/)

The first time you run the Application, you may get an error like `undefined method links for nil NilClass`. This is because you are missing the required entries in the ContentStore for each Finder. To fix this:

1. Clone `[alphagov/content-store](http://github.com/alphagov/content-store)`, `[alphagov/router-api](https://github.com/alphagov/router-api)` and `[alphagov/url-arbiter](https://github.com/alphagov/url-arbiter)` and `bundle install` in each Repo.
2. Start the `publishing-api` with bowl. This is a meta-application which will start the 3 Applications mentioned in step 1.
3. In [alphagov/finder-api](http://github.com/alphagov/finder-api), run `bundle exec rake publishing_api:publish`

##Running the test suite

```
$ bundle exec rake
```

The application has jasmine tests, which can be accessed at `/specs` when the application is running in development mode. These are also run when `rake`, above, is run.

##Making a new finder
1. Add a schema to [alphagov/rummager](http://github.com/alphagov/rummager) describing your document type -- eg
   [https://github.com/alphagov/rummager/blob/master/config/schema/default/doctypes/cma_case.json](https://github.com/alphagov/rummager/blob/master/config/schema/default/doctypes/cma_case.json)
2. Add a schema to [alphagov/finder-api](http://github.com/alphagov/finder-api) describing the facets -- eg
   [https://github.com/alphagov/finder-api/blob/master/schemas/cma-cases.json](https://github.com/alphagov/finder-api/blob/master/schemas/cma-cases.json)
3. Add a new AbstractDocument subclass (eg app/models/cma_case.rb)
4. Map your new document type to this new subclass in:
   * `lib/finder_frontend.rb#presenter_class`
   * `app/parsers/document_parser.rb#parse`
5. Map your finder slug to your document type in `app/models/finder.rb#document_type`
6. Ensure your documents are indexed in [alphagov/rummager](http://github.com/alphagov/rummager).

##Application structure
* No data store -- all data comes via the APIs mentioned above.
* `app/models` contains two kinds of object.
  1. Value objects used to wrap up responses from API calls.
  2. Facet objects which wrap up the behaviour of different types of facet --
     eg radios, selects, etc.
* `app/presenters` contains objects which serialise the value objects to hashes
  for display via mustache.
* `app/parsers` contains objects which transform API responses into models.
