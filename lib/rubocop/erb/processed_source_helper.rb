# frozen_string_literal: true

module RuboCop
  module Erb
    module ProcessedSourceHelper
      # Creates a new ProcessedSource, inheriting state from a donor
      #
      # @param [RuboCop::ProcessedSource] input_processed_source
      # @param [String] code
      # @return [RuboCop::ProcessedSource]
      def self.code_to_processed_source(input_processed_source, path, code)
        supports_prism = input_processed_source.respond_to?(:parser_engine)
        processed_source = if supports_prism
                             ::RuboCop::ProcessedSource.new(
                               code,
                               input_processed_source.ruby_version,
                               path,
                               parser_engine: input_processed_source.parser_engine
                             )
                           else
                             ::RuboCop::ProcessedSource.new(
                               code,
                               input_processed_source.ruby_version,
                               path
                             )
                           end
        processed_source.config = input_processed_source.config
        processed_source.registry = input_processed_source.registry
        processed_source
      end
    end
  end
end
