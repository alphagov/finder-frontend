# Make changes to Brexit Checker content

Finder frontend serves lists of actions to take related to Brexit.

Content editors request changes to the actions, questions, and criteria via
Zendesk.

### Contents:

- [Updates to actions](#updates-to-actions)
- [Adding change notes](#adding-change-notes)

## Updates to actions

Actions are defined in [an `actions.yaml` file](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/actions.yaml). To add or change an action, you'll need to run one of the following rake tasks. When the file has changed in multiple ways, only commit the changes that were requested.

**NOTE: Additions or changes to actions may require a [change note](#adding-change-notes). Check with the person who requested the change.**

**NOTE: It's a good idea to run `bundle exec rspec spec/integration/brexit_checker_spec.rb` to validate the Yaml locally, before raising a PR.**

### If the CSV is available from Google Sheets
1. Create a `.env` file and add the sheet ID (this can be found in the URL of the Google Sheet) as an environment variable. For example:

```
GOOGLE_SHEET_ID="a-google-sheet-id"
```

2. Before you run the rake task for the first time, you will need to enable to Google Drive API by generating a `credentials.json` file from the API.  Instructions to to this can be found [here](https://developers.google.com/drive/api/v3/quickstart/ruby).  You will not need to do this again when running the rake task in future as long as you have `credentials.json`.

3. Run this take task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions_from_google_drive
```

### If the CSV is available as a standalone file

Run this take task:

```
bundle exec rake brexit_checker:convert_csv_to_yaml:actions[path/to/actions.csv]`
```

## Adding change notes

Additions or changes to actions may require a change note, which is used to send a notification about the change. Change notes should only be created for this purpose.

Change notes are defined [in a `change_notes.yaml` file](https://github.com/alphagov/finder-frontend/blob/master/lib/brexit_checker/change_notes.yaml). You should check with the person who requested the change, to determine if a change note is appropriate.

When a new change note has been deployed to production, you need to run a rake task to send the notification. The notification will be sent to all subscribers who would see this action on their results page.

https://deploy.blue.production.govuk.digital/job/run-rake-task/parambuild/?TARGET_APPLICATION=finder-frontend&MACHINE_CLASS=calculators_frontend&RAKE_TASK=brexit_checker:change_notification[UUID]
