# Q&A frontend

![Q&A frontend screenshot](assets/q-and-a-screenshot.png)

The Q&A frontend is a finder-frontend feature that walks users through the facets for a given finder with one facet per page.

Any, all or no filters can be selected for each facet, and any question may be skipped. At the end of the process, the user is directed to the given finder with their selections intact.

It follows the [question pages pattern from the design system](https://design-system.service.gov.uk/patterns/question-pages/). It differs from [Smart Answers](https://github.com/alphagov/smart-answers) in that it uses the answers to each question to generate a URL which preselects facets on a finder.

The Q&A feature has been defined for one finder - [/prepare-business-uk-leaving-eu](https://www.gov.uk/prepare-business-uk-leaving-eu) - and relies on a YAML file [prepare_business_uk_leaving_eu.yaml](../lib/prepare_business_uk_leaving_eu.yaml).

The YAML file defines:

- The base path of the Q&A and the underlying finder. Therefore, multiple Q&As can be created by defining multiple YAML files.
- Titles of the questions are defined in the YAML file.
- The type of select element that is rendered (e.g. checkbox or radio button) is also defined in the YAML file, as is the ordering and grouping of checkboxes.
