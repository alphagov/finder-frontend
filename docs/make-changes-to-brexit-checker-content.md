# Make changes to Brexit Checker content

Finder frontend serves lists of actions to take related to Brexit.

Content editors request changes to the actions, questions, and criteria via
Zendesk.

For these changes to reach users, a developer needs to change the content in
Yaml files in [lib/brexit_checker](https://github.com/alphagov/finder-frontend/tree/master/lib/brexit_checker). Once the change has been made
(raise a PR, and merge in the updated Yaml), then run a rake task to update
subscribed users of this change via email.

### Contents:

- [Update actions](#update-actions)
- [Add change notes](#adding-change-notes)
- [Send updates to subscribed users](#send-updates-to-subscribed-users)

## Update actions

To add, remove, or change an action, you'll need to run a rake task to convert an actions CSV to `actions.yaml`.  After running one of the rake tasks below, run `bundle exec rspec spec/lib/brexit_checker` to run tests against the Yaml. This will ensure it has the right format. For example, the `action_id` must be unique.

Review the diff for `lib/brexit_checker/actions.yaml` and commit only the changes that
the content designer requested.

**NOTE: A change note should be created for all major changes to actions.**

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
