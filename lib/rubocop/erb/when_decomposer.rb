# frozen_string_literal: true

module RuboCop
  module Erb
    class WhenDecomposer
      REGEXP = /
        \A
        \s*
        when[ \t]
      /x.freeze

      class << self
        # @param [RuboCop::ProcessedSource] processed_source
        # @param [RuboCop::Erb::RubyClip] ruby_clip
        # @return [Array<RuboCop::Erb::RubyClip>]
        def call(
          processed_source,
          ruby_clip
        )
          new(processed_source, ruby_clip).call
        end
      end

      # @param [RuboCop::ProcessedSource] processed_source
      # @param [RuboCop::Erb::RubyClip] ruby_clip
      def initialize(
        processed_source,
        ruby_clip
      )
        @processed_source = processed_source
        @ruby_clip = ruby_clip
      end

      # @return [Array<RuboCop::Erb::RubyClip>]
      def call
        match_data = @ruby_clip.code.match(REGEXP)
        if match_data
          offset = match_data[0].length
          condition = @ruby_clip.code[offset..].sub(/[ \t]then(?:[ \t].*)?/, '')
          nodes = parse(
            <<~RUBY
              [
                #{condition}
              ]
            RUBY
          )&.children || []

          nodes.map do |child|
            RubyClip.new(
              code: child.location.expression.source,
              offset: @ruby_clip.offset + offset + child.location.expression.begin_pos - 4
            )
          end
        else
          [@ruby_clip]
        end
      end

      private

      # @param [String] source
      # @return [RuboCop::AST::Node]
      def parse(source)
        ProcessedSourceBuilder.call(
          code: source,
          processed_source: @processed_source
        ).ast
      end
    end
  end
end
