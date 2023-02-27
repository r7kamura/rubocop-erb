# rubocop-erb

[![test](https://github.com/r7kamura/rubocop-erb/actions/workflows/test.yml/badge.svg)](https://github.com/r7kamura/rubocop-erb/actions/workflows/test.yml)

[RuboCop](https://github.com/rubocop/rubocop) plugin for ERB template.

## Installation

Install the gem and add to the application's Gemfile by executing:

```
bundle add rubocop-erb
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
gem install rubocop-erb
```

## Usage

Require `rubocop-erb` in your RuboCop config.

```yaml
# .rubocop.yml
require:
  - rubocop-erb
```

Now you can use RuboCop also for ERB templates.

```
$ bundle exec rubocop spec/fixtures/dummy.erb
Inspecting 1 file
C

Offenses:

spec/fixtures/dummy.erb:1:4: C: [Correctable] Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
<% "a" %>
   ^^^
spec/fixtures/dummy.erb:4:9: C: [Correctable] Style/ZeroLengthPredicate: Use !empty? instead of size > 0.
<% a if array.size > 0 %>
        ^^^^^^^^^^^^^^
spec/fixtures/dummy.erb:5:4: C: [Correctable] Style/NegatedIf: Favor unless over if for negative conditions.
<% a if !b %>
   ^^^^^^^
spec/fixtures/dummy.erb:7:7: C: [Correctable] Style/StringLiterals: Prefer single-quoted strings when you don't need string interpolation or special symbols.
<% if "a" %>
      ^^^

1 file inspected, 4 offenses detected, 4 offenses autocorrectable
```

## Workaround

As a known issue, there seems to be a problem with .rubocop_todo.yml overriding config/default.yml provided by rubocop-erb, so we recommend adding a workaround to your .rubocop.yml as shown below:

```yaml
inherit_from: .rubocop_todo.yml

inherit_mode:
  merge:
    - Exclude
```

See [#15](https://github.com/r7kamura/rubocop-erb/issues/15) for more details.

## Related projects

- https://github.com/r7kamura/rubocop-haml
- https://github.com/r7kamura/rubocop-slim
- https://github.com/r7kamura/rubocop-markdown
