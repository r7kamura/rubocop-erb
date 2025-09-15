# frozen_string_literal: true

require_relative 'lib/rubocop/erb/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-erb'
  spec.version = RuboCop::Erb::VERSION
  spec.authors = ['Ryo Nakamura']
  spec.email = ['r7kamura@gmail.com']

  spec.summary = 'RuboCop plugin for ERB template.'
  spec.homepage = 'https://github.com/r7kamura/rubocop-erb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Erb::Plugin'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'better_html'
  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '~> 1.72', '>= 1.72.1'
end
