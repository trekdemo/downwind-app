---
paths:
  - "app/assets/tailwind/**/*.css"
  - "app/assets/stylesheets/**/*.css"
  - "app/views/**/*.erb"
  - "app/helpers/**/*.rb"
  - "app/controllers/**/*.rb"
  - "app/javascript/controllers/**/*.js"
  - "app/models/color_scale.rb"
---

# Keep the design components page in sync

`/admin/design_components` is the living style guide that theming work relies on:

- `app/views/admin/design_components/index.html.erb` shows every shared component.
- `COLOR_ROLES` in `app/helpers/admin/design_components_helper.rb` lists every colour, with its semantic role and where it is used.

Before finishing a session that changed any of the files above, check whether the change affects the style guide. Update the style guide in the same change when it does:

- **New or changed component.** This covers a new or edited `@utility` in `app/assets/tailwind/application.css`, a new shared partial or UI helper, and a class string used in more than one place. Add or update its `design_example`, using the same classes, partial or helper as the app. Keep the `source:` label pointing at the file that defines it.
- **Removed component.** Delete its example.
- **New colour.** This covers a Tailwind colour class, an opacity variant or a hard-coded hex value, for example chart datasets in controllers or colours in the `chart` and `map` Stimulus controllers. Add it to `COLOR_ROLES` under the matching role, or under a new role if none fits.
- **Colour that changed or is no longer used somewhere.** Update the `usage:` text. Remove the entry if nothing uses the colour any more.
- **New icon.** It appears in the icons grid automatically through `icon_names`. No change is needed.

Then run `bundle exec rspec spec/requests/admin/design_components_spec.rb`.

If the change has no visual effect, such as pure logic in a controller or helper, say so in one line and move on.
