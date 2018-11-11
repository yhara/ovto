## v0.2.2 (2018-11-07)

- security: Update rack

## v0.2.1 (2018-11-02)

- fix: gem install error on Windows (due to symlink)

## v0.2.0 (2018-11-01)

New features

- First gem release!
- `Ovto.fetch`
- Calling another action from actions
- Allow `o "div#id.class"` or `o "div.class#id"`
- Sub component can access the app state by adding `state:` keyword to `render`
- `App#actions`, `App#setup`
- `State#==`
- `console.log`

Fixes

- Skip rendering if app state is not changed by an action
- `o "div.main", class: 'hovered'` should yield `<div class='main hovered'>`
- Cannot pass falsy value when rendering a child component

## v0.1.0 (2018-06-01)

- Initial release
