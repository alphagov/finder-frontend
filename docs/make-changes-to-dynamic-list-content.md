# Make changes to dynamic list content

Finder frontend serves lists of actions to take related to Brexit.

Content editors request changes to the actions, questions, and criteria via
Zendesk.

For these changes to reach users, a developer needs to change the content in
Yaml files in [lib/checklists](https://github.com/alphagov/finder-frontend/tree/master/lib/checklists). Once the change has been made
(raise a PR, and merge in the updated Yaml), then run a rake task to update
subscribed users of this change via email.

### Contents:

- [Update actions](#update-actions)
- [Add change notes](#adding-change-notes)
- [Send updates to subscribed users](#send-updates-to-subscribed-users)

## Update actions

To add, remove, or change an action, you'll need to edit the actions file
at [lib/checklists/actions.yaml](https://github.com/alphagov/finder-frontend/tree/master/lib/checklists/actions.yaml). See the yaml file for examples.

A content editor should supply you with the data you need.

Run `bundle exec rspec spec/lib/checklists` to run tests against the Yaml. This will ensure it has
the right format. For example, the `action_id` must be unique.

**NOTE: A change note should be created for all major changes to actions.**

## Adding change notes

When making changes to actions, you may also need to create a change note.

This will involve adding an entry to the [lib/checklists/changenotes.yaml](https://github.com/alphagov/finder-frontend/tree/master/lib/checklists/changenotes.yaml)
file. See the yaml file for examples.

The text should be provided by the content editor. This content will be
included in emails to users.

If a change note is created, users will be emailed about the change. Without
a change note, users will not be emailed.

Don't modify change notes, always add new ones. Change note IDs must be unique.

## Send updates to subscribed users

*TODO* Add details of rake task to update users of changes to actions.
