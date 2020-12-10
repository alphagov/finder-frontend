# Make changes to Transition Checker content

The Transition Checker is a question and answer tool which informs a user of actions to take related to the Transition period. It can be found at [https://www.gov.uk/transition-check/questions](https://www.gov.uk/transition-check/questions).

Content editors request changes to the actions, questions, and criteria via Zendesk. GDS content designers triage and process these requests, updating their canonical Google Sheet (aka the Dynamic List) as required.

## Updates to actions

Actions are defined in an [ `actions.yaml`](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/actions.yaml) file, which is automatically populated from the  Google Sheet. To add or change an action, you'll need to complete the following steps:

1. The content designer requesting the change should provide you with a link to the canonical Google Sheet. At time or writing, the sheet is located [here](https://docs.google.com/spreadsheets/d/1wIeBTitJVfkWa7oKrGmusIo2r4TsvXVdlne_xG6YjYs/edit?usp=sharing)

2. Make sure you have finder-frontend checked out locally. Create a `.env` file in the root of the finder-frontend repo. Your file should look like this:

```
# EXAMPLE: for given sheet https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
# id="1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
GOOGLE_SHEET_ID="1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
```

3. Enable the Google Drive API by generating a `credentials.json` file from the API and saving it in the root directory of the repo.  Instructions for this can be found [here](https://developers.google.com/drive/api/v3/quickstart/ruby#step_1_turn_on_the). You will be prompted for the following information:
  - Project name. (It doesn't matter what you enter here)
  - Configure your OAuth client. (Select Desktop App)

You will not need to do this again when running the rake task in future as long as you have `credentials.json`.

4. Run this rake task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions_from_google_drive
```

5. Sometimes changes are made to the Google Sheet which are not ready to deploy yet. Double check the diff against the changes that have been requested. Only commit changes that have been requested.

6. Run `bundle exec rspec spec/integration/brexit_checker_spec.rb` to validate the yaml locally, before raising a PR

7. A heroku review app should be automatically generated when you raise the PR. Share this with the content designer requesting the change so they can review the changes before they are deployed.

**NOTE: Additions or changes to actions may require a [notification](#adding-notifications). Check with the person who requested the change.**

## Adding notifications

When new actions are added to the checker, or existing actions are changed, it is sometimes necessary to send a notification email to alert subscribers. Generally the content designer requesting the change will specify if a notification is required, and if it should contain a change note. For reference, [these](https://docs.google.com/document/d/1YbXLRJ_FkPDvYPC7e4Nkhm054LqFVydn-KX_Th3yFYw/edit?usp=sharing) are the rules.

If a notification is needed, follow these steps:

1. Add the relevant details to the [notifications.yaml](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/notifications.yaml) file. There is a handy [rake task](https://github.com/alphagov/finder-frontend/blob/master/lib/tasks/brexit_checker/change_notifications.rake) to generate valid yaml that can be copied into the file.

  Example usage:
  ```
  rake brexit_checker:configure_notifications NEW_ACTIONS="A001 A099" CHANGED_ACTIONS="S007"
  ```

  Will output:

  ```
  ---
  notifications:
  - uuid: f2a677fb-6350-4329-8969-848723410526
    type: addition
    action_id: A001
    date: '2020-12-10'
  - uuid: 56ff9c67-40b4-4c7f-9842-d9503212ff88
    type: addition
    action_id: A099
    date: '2020-12-10'
  - uuid: 71dd9005-06e5-4e40-ac5a-85f28c60862a
    type: content_change
    action_id: S007
    date: '2020-12-10'
    note: INSERT CHANGE NOTE HERE
  ```

2. Open a PR to get the new notification(s) merged to master.

3. To send the notification email(s), run the following rake task.

  https://deploy.blue.production.govuk.digital/job/run-rake-task/parambuild/?TARGET_APPLICATION=finder-frontend&MACHINE_CLASS=calculators_frontend&RAKE_TASK=brexit_checker:change_notification[UUID]

  The email will be sent to all subscribers who would see this action on their results page:

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

You can add criteria to a notification in `notifications.yaml`. If a notification has criteria the rake file will [use these values](https://github.com/alphagov/finder-frontend/blob/0d95a648088e50620810ef5c6830a32a113f3a68/app/lib/brexit_checker/notifications/payload.rb#L10) to determine which subscribers to notify. This will override the default of notifying users based on criteria from the action.

## If the CSV is available as a standalone file
In some cases you may be required to upload content changes from a Google Sheet that's separate from the main sheet. This is advised against as the main sheet should always be up to date.

However, if this is needed, you can run the following rake task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions[path/to/actions.csv]`
```
