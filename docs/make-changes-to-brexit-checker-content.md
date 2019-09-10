# Make changes to Brexit Checker content

Finder frontend serves lists of actions to take related to Brexit.

Content editors request changes to the actions, questions, and criteria via
Zendesk.

### Contents:

- [Updates to actions](#updates-to-actions)
- [Adding change notes](#adding-change-notes)
- [Send updates to subscribed users](#send-updates-to-subscribed-users)

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

When making changes to actions, you may also need to create a change note.

This will involve adding an entry to the [lib/brexit_checker/changenotes.yaml](https://github.com/alphagov/finder-frontend/tree/master/lib/brexit_checker/changenotes.yaml)
file. See the yaml file for examples.

The text should be provided by the content editor. This content will be
included in emails to users.

If a change note is created, users will be emailed about the change. Without
a change note, users will not be emailed.

Don't modify change notes, always add new ones. Change note IDs must be unique.

## Send updates to subscribed users

*TODO* Add details of rake task to update users of changes to actions.
