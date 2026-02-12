# Jekyll Lucide

A Jekyll plugin that provides [Lucide](https://lucide.dev) icons as inline SVGs via a Liquid tag.

Adapted from [lucide-rails](https://github.com/heyvito/lucide-rails).

## Installation

Add the gem to your Jekyll site's Gemfile:

```ruby
gem "jekyll-lucide"
```

Then run `bundle install`.

Add the plugin to your `_config.yml`:

```yaml
plugins:
  - jekyll-lucide
```

## Usage

Use the `lucide_icon` Liquid tag in your templates:

```liquid
{% lucide_icon "home" %}
{% lucide_icon "arrow-right" size="32" class="my-icon" %}
{% lucide_icon "search" stroke-width="1.5" %}
```

You can also use variables for the icon name:

```liquid
{% lucide_icon page.icon %}
{% lucide_icon item.icon_name size="20" %}
```

### Options

| Option         | Description                            |
| -------------- | -------------------------------------- |
| `size`         | Sets both `width` and `height`         |
| `class`        | CSS class(es) to add to the SVG        |
| `stroke-width` | Stroke width (default: `2`)            |
| `stroke`       | Stroke color (default: `currentColor`) |
| `fill`         | Fill color (default: `none`)           |

Any valid SVG attribute can be passed as an option.

### Default Attributes

All icons include these default attributes:

```html
aria-hidden="true"
width="24"
height="24"
viewBox="0 0 24 24"
fill="none"
stroke="currentColor"
stroke-width="2"
stroke-linecap="round"
stroke-linejoin="round"
```

### Configuration

Set default attributes for all icons in `_config.yml`:

```yaml
lucide:
  defaults:
    class: "lucide-icon"
    stroke-width: "1.5"
```

### Custom Icons

You can override bundled Lucide icons or add your own by placing SVG files in a `_lucide/` directory in your site root. Files should contain inner SVG content only (no outer `<svg>` tags), matching the format of the bundled icons.

```
_lucide/
  github.svg    # overrides the bundled github icon
  my-logo.svg   # a new custom icon
```

Then use them like any other icon:

```liquid
{% lucide_icon "github" %}
{% lucide_icon "my-logo" size="32" %}
```

You can use the `jekyll-lucide` CLI to install SVG files as custom icons. It strips the outer `<svg>` tags automatically:

```bash
bundle exec jekyll-lucide install-icon logo.svg
bundle exec jekyll-lucide install-icon --dir _my_icons logo.svg
bundle exec jekyll-lucide install-icon --name my-logo logo.svg
bundle exec jekyll-lucide install-icon icon1.svg icon2.svg
```

The resolution order is:

1. `_lucide/{name}.svg` (custom/override)
2. Bundled Lucide icon
3. Error if neither exists

To use a different directory, set `custom_icons_dir` in `_config.yml`:

```yaml
lucide:
  custom_icons_dir: _my_icons
```

## Available Icons

See the full list of available icons at [lucide.dev/icons](https://lucide.dev/icons).

## Updating Icons

To fetch the latest icons from Lucide:

```bash
bin/fetch-icons
```

This clones the Lucide repository, processes the SVGs, and updates `lib/jekyll-lucide/lucide_version.rb`.

## License

MIT
