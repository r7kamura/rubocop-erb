# frozen_string_literal: true

require 'herb'
require 'rubocop'

module RuboCop
  module Erb
    # Extract Ruby codes from ERB template.
    class RubyExtractor
      class << self
        # @param [RuboCop::ProcessedSource] processed_source
        # @return [Array<RuboCop::ProcessedSource>, nil]
        def call(processed_source)
          new(processed_source).call
        end
      end

      # @param [RuboCop::ProcessedSource] processed_source
      def initialize(processed_source)
        @processed_source = processed_source
      end

      # @return [Array<RuboCop::ProcessedSource>, nil]
      def call
        return unless supported_file_path_pattern?

        new_processed_source = ERBSource.new(template_source,
                                             extracted_ruby,
                                             @processed_source.ruby_version,
                                             @processed_source.path,
                                             parser_engine: @processed_source.parser_engine)
        new_processed_source.config = @processed_source.config
        new_processed_source.registry = @processed_source.registry
        [{
          offset: 0,
          processed_source: new_processed_source
        }]
      end

      private

      # The extracted Ruby, character-aligned with the template.
      #
      # `Herb.extract_ruby` blanks non-Ruby bytes to spaces, which expands every
      # multi-byte character (e.g. an emoji in the HTML) into several spaces and
      # shifts the position of all following characters. Since corrections map
      # extracted positions back to the template 1:1, re-collapse those runs so a
      # multi-byte source character stays a single character.
      #
      # @return [String]
      def extracted_ruby
        extracted = Herb.extract_ruby(template_source)
        return extracted if extracted.length == template_source.length

        realigned = +''
        byte_index = 0
        template_source.each_char do |char|
          size = char.bytesize
          chunk = extracted.byteslice(byte_index, size)
          realigned << (size == 1 || chunk == char ? chunk : ' ')
          byte_index += size
        end
        realigned
      end

      # @return [String, nil]
      def file_path
        @processed_source.path
      end

      # @return [Boolean]
      def supported_file_path_pattern?
        file_path&.end_with?('.erb')
      end

      # @return [String]
      def template_source
        @processed_source.raw_source
      end
    end
  end
end
