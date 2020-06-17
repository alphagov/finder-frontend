# Make changes to Transition Checker content

The Transition Checker is a question and answer tool which informs a user of actions to take related to the Transition period. It can be found at [https://www.gov.uk/transition-check](https://www.gov.uk/transition-check).

Content editors request changes to the actions, questions, and criteria via Zendesk.

## Updates to actions

Actions are defined in [an `actions.yaml` file](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/actions.yaml), which is automatically populated from a Google Sheet. To add or change an action, you'll need to complete the following steps:

1. The content designer requesting the change should provide you with a link to the Google Sheet.

2. Make sure you have finder-frontend checked out locally. Create a `.env` file in the root of the finder-frontend repo. Your file should look like this:

```
# EXAMPLE: for given sheet https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
# id="1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
GOOGLE_SHEET_ID="1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
```

3. Enable the Google Drive API by generating a `credentials.json` file from the API and saving it in the root directory of the repo.  Instructions for this can be found [here](https://developers.google.com/drive/api/v3/quickstart/ruby).  You will not need to do this again when running the rake task in future as long as you have `credentials.json`.

4. Run this rake task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions_from_google_drive
```

5. Sometimes changes are made to the Google Sheet which are not ready to deploy yet. Double check the diff against the changes that have been requested. Only commit changes that have been requested.

6. Run `bundle exec rspec spec/integration/brexit_checker_spec.rb` to validate the yaml locally, before raising a PR

7. A heroku review app should be automatically generated when you raise the PR. Share this with the content designer requesting the change so they can review the changes before they are deployed.

**NOTE: Additions or changes to actions may require a [notification](#adding-notifications). Check with the person who requested the change.**

## Adding notifications

Additions or changes to actions may require a notification, which sends an email to alert subscribers to a change. Notifications should only be created for this purpose.

Notifications are defined in the [notifications.yaml file](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/notifications.yaml). You should check with the person who requested the change, to determine if a notification is appropriate.

If a notification is needed, add the relevant details to the [notifications.yaml file](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/notifications.yaml). You will need to generate a UUID for each notification. You can do this in an interactive Ruby shell (IRB):

```
> irb
> require 'securerandom'
> SecureRandom.uuid
```

To send a notification, run the following rake task. The notification email will be sent to all subscribers who would see this action on their results page:

https://deploy.blue.production.govuk.digital/job/run-rake-task/parambuild/?TARGET_APPLICATION=finder-frontend&MACHINE_CLASS=calculators_frontend&RAKE_TASK=brexit_checker:change_notification[UUID]

### Notifying a subset of subscribers

Sometimes you will only want to notify a subset of subscribers. For example when content remains the same but the criteria for an action has changed.

Notifications have an optional attribute `criteria`. The structure and format of this criteria is the same as criteria from an action, for example:

```yaml
uuid: "f37f8452-c81d-4cd6-82ce-6930a8a50b6d"
type: addition
action_id: S011
date: 2019-10-07
criteria:
- all_of:
  - nationality-uk
  - any_of:
    - living-ie
    - living-eu
  - visiting-eu
```

You can add criteria to a notification in `notifications.yaml`. If a record has criteria the rake file will [use these values](https://github.com/alphagov/finder-frontend/blob/0979c94ec51ba38f8d574569ffd51ffea55f13a6/lib/tasks/brexit_checker/change_notifications.rake#L10) to notify subscribers. This will override the default of notifying users based on criteria from the action.

## If the CSV is available as a standalone file
In some cases you may be required to upload content changes from a Google Sheet that's separate from the main sheet. This is advised against as the main sheet should always be up to date.

However, if this is needed, you can run the following rake task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions[path/to/actions.csv]`
```

