# frozen_string_literal: true

require 'rubocop/rspec/support'

module RuboCop
  module Erb
    module TestHelper
      include ::RuboCop::RSpec::ExpectOffense

      private

      # @note Overriding to work well with Ruby extractor.
      def _investigate(
        cop,
        processed_source
      )
        ::RuboCop::Runner.ruby_extractors.find do |ruby_extractor|
          result = ruby_extractor.call(processed_source)
          break result if result
        end.flat_map do |extracted_ruby_source|
          report = ::RuboCop::Cop::Team.new(
            [cop],
            nil,
            raise_error: true
          ).investigate(
            extracted_ruby_source[:processed_source],
            offset: extracted_ruby_source[:offset],
            original: processed_source
          )
          @last_corrector = ::RuboCop::Cop::Corrector.new(processed_source)
          if report.correctors.first
            @last_corrector = @last_corrector.import!(
              report.correctors.first,
              offset: extracted_ruby_source[:offset]
            )
          end
          report.offenses.reject(&:disabled?)
        end
      end

      # @note Overriding to avoid raising an error when the source is not valid Ruby code.
      def inspect_source(
        source,
        file = nil
      )
        ::RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
        ::RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
        _investigate(
          cop,
          parse_source(source, file)
        )
      end

      # @note Overriding to avoid raising an error when the source is not valid Ruby code.
      def parse_processed_source(
        source,
        file = nil
      )
        parse_source(source, file)
      end
    end
  end
end
