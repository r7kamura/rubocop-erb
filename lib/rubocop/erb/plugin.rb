# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Erb
    # A plugin that integrates rubocop-erb with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          description: 'RuboCop plugin for ERB template.',
          homepage: 'https://github.com/r7kamura/rubocop-erb',
          name: 'rubocop-erb',
          version: VERSION
        )
      end

      def rules(_context)
        RuboCop::Runner.ruby_extractors.unshift(RuboCop::Erb::RubyExtractor)

        LintRoller::Rules.new(
          config_format: :rubocop,
          type: :path,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end
    end
  end
end
