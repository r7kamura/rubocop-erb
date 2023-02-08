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

Require `"rubocop-erb"` in your RuboCop config.

```yaml
# .rubocop.yml
require:
  - rubocop-erb
```

Now you can use RuboCop also for ERB templates.

```
$ bundle exec rubocop spec/fixtures/dummy.erb
Inspecting 1 file
E

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
spec/fixtures/dummy.erb:7:11: E: Lint/Syntax: unexpected token $end
(Using Ruby 2.6 parser; configure using TargetRubyVersion parameter, under AllCops)
<% if "a" %>


1 file inspected, 4 offenses detected, 3 offenses autocorrectable
```
