# frozen_string_literal: true

module RuboCop
  module Erb
    class ProcessedSourceBuilder
      class << self
        # Creates a new ProcessedSource, inheriting state from a donor.
        #
        # @param [String] code
        # @param [RuboCop::ProcessedSource] processed_source
        # @return [RuboCop::ProcessedSource]
        def call(
          code:,
          processed_source:
        )
          new(
            code: code,
            processed_source: processed_source
          ).call
        end
      end

      def initialize(
        code:,
        processed_source:
      )
        @code = code
        @processed_source = processed_source
      end

      def call
        new_processed_source = ::RuboCop::ProcessedSource.new(
          @code,
          @processed_source.ruby_version,
          @processed_source.path,
          parser_engine: @processed_source.parser_engine
        )
        new_processed_source.config = @processed_source.config
        new_processed_source.registry = @processed_source.registry
        new_processed_source
      end
    end
  end
end
