# frozen_string_literal: true

module RuboCop
  module Erb
    module ProcessedSourceBuilder
      class << self
        # Creates a new ProcessedSource, inheriting state from a donor.
        #
        # @param [String] code
        # @param [String] path
        # @param [RuboCop::ProcessedSource] processed_source
        # @return [RuboCop::ProcessedSource]
        def call(
          code:,
          path:,
          processed_source:
        )
          supports_prism = processed_source.respond_to?(:parser_engine)
          new_processed_source =
            if supports_prism
              ::RuboCop::ProcessedSource.new(
                code,
                processed_source.ruby_version,
                path,
                parser_engine: processed_source.parser_engine
              )
            else
              ::RuboCop::ProcessedSource.new(
                code,
                processed_source.ruby_version,
                path
              )
            end
          new_processed_source.config = processed_source.config
          new_processed_source.registry = processed_source.registry
          new_processed_source
        end
      end
    end
  end
end
