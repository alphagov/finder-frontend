# Brexit Checker

Finder frontend is responsible for the question and answer workflow of the "Get Ready for Brexit" Checker (aka Dynamic Lists). The tool allows users to answer a series of questions and then presents a list of "actions" that are relevant to them.

## Data model
Main concepts for the Brexit Checker include:

### Criterion
Criteria are facts that we know about the user e.g. "a UK National" or "owns a business". A single criterion aims to be small in scope so that we can use a list of criteria to build up a picture of a user's circumstances. 

A criterion has the following attributes:

| attribute | values | description                | required |
|-----------|--------|----------------------------|----------|
| key       | string | human readable unique id   | yes      |
| text      | string | human readable description | yes      |

There may be dependencies between criteria e.g. you cannot have 'employs EU citizens' without 'owns a business'. Resolution of these dependencies is currently determined by the question flow, this is covered under the [Question section](#question). Knowing these dependencies allows us to deduce a subset of criteria which is actually applicable to a user.

### Criteria Rule
A Criteria Rule is an object which can be evaluated against a set of criteria and resolves to boolean true or false value.

| attribute | values                                   | description                                                          | required                 |
|-----------|------------------------------------------|----------------------------------------------------------------------|--------------------------|
| all_of    | array of criteria keys or Criteria Rules | returns true when all elements of the array are present or also true | if any_of is not present |
| any_of    | array of criteria keys or Criteria Rules | returns true when any element of the array is present or also true   | if all_of is not present |

Note that the attributes `all_of` and `any_of` cannot both be specified together at the same level e.g.

```
any_of:
  - apple
all_of:
  - banana
```


#### Example of `all_of`

```
all_of:
 - apple
 - banana
```

Maps to the boolean logic `apple AND banana`, and is true for the sets of criteria `(apple, banana)` or `(apple, banana, cherry)`, but false for `(apple)` or `(banana, cherry)`


#### Example of `any_of`

```
any_of:
 - apple
 - banana
```

Maps to the boolean logic `apple OR banana`, and is true for the sets of criteria `(apple)` or `(banana)`, but false for `(cherry)`

#### Example of nested criteria rules

```
all_of:
 - apple
 - banana
 - any_of:
   - cherry
   - date
```

Maps to the boolean logic `apple AND banana AND (cherry OR date)`, and is true for the sets of criteria `(apple, banana, cherry)` or `(apple, banana, date)`, but false for `(apple, banana)` or `(apple, cherry, date)`

### Action
An action represents a task for a user to do. It encapsulates the information of what that task is and how the user might carry it out. An action has criteria rules to determine if it is relevant for a user's set of criteria. 

A action has the following attributes:

| attribute          | value                          | description                                                                                | required                         |
|--------------------|--------------------------------|--------------------------------------------------------------------------------------------|----------------------------------|
| id                 | string                         | unique id                                                                                  | yes                              |
| title              | string                         | description of what action needs to be taken                                               | yes                              |
| title_url          | string                         | url to a service that helps a user carry out that action                                   | no                               |
| consequence        | string                         | description of what happens if the action is not completed                                 | yes                              |
| exception          | string                         | description of user's circumstances where this action may not apply                        | no                               |
| lead_time          | string                         | time it takes to complete the action                                                       | yes                              |
| priority           | integer                        | relative measure of urgency compared to other actions - larger numbers are higher priority | yes                              |
| guidance_prompt    | string                         | prefix statement before the guidance_link_text is displayed                                | yes                              |
| guidance_link_text | string                         | title of the guidance on how to complete the action                                        | if guidance_url is present       |
| guidance_url       | string                         | url to guidance on how complete the action                                                 | if guidance_link_text is present |
| audience           | either 'citizen' or 'business' | grouping label                                                                             | yes                              |
| criteria           | Criteria Rule                  | defines which sets of criteria the action applies to                                        | yes                              |

### Question
A question represents a way to elicit information about a user and the possible answers that a user can give. Each answer (represented by an Option) maps to a criterion that can be applied to the user. For example, the question "Do you own a business?" may have the options "Yes" and "No". If the user responded "Yes", they would be attributed with the criterion "owns-a-business". 

A question has the following attributes:

| attribute   | values                                                            | description                                                        | required |
|-------------|-------------------------------------------------------------------|--------------------------------------------------------------------|----------|
| key         | string                                                            | unique id                                                          | yes      |
| type        | either 'single', 'single_wrapped', 'multiple', 'multiple_grouped' | determines the style and behaviour of the question                 | yes      |
| text        | string                                                            | question text                                                      | yes      |
| hint_text   | string                                                            | description on how to make a answer selection                      | no       |
| description | string                                                            | additional context on the question being asked                     | no       |
| options     | array of Options                                                  | list of possible answers                                           | yes      |
| criteria    | Criteria Rule                                                     | defines which sets of criteria the question should be presented | no       |

Question can be conditionally shown depending on the user's current list of criteria. This allows us to support different question flows depending on a users circumstances e.g. we don't show questions about businesses if they answered they don't own a business. This also implicitly models a criterion's dependencies. If a question depends on a criterion, then the associated criteria in the options also depend on that criterion.  

### Option
An option is an single answer that can be given to a question. Each option maps to a single criterion that can be applied to a user. 

A option has the following attributes:

| attribute   | values           | description                                                                                                     | required |
|-------------|------------------|-----------------------------------------------------------------------------------------------------------------|----------|
| label       | string           | human readable answer text, needs to be written in the context of the question                                  | yes      |
| value       | string           | criteria key in which to apply to the user if the option is selected                                            | yes      |
| sub_options | array of Options | additional options that are available if option is selected, primarily used for the 'single_wrapped' type questions | no       |
| hint_text   | string           | addition context to help the user understand the option                                                         | no       |
| criteria    | Criteria Rule    | defines which sets of criteria the option should be shown                                                       | no       |

