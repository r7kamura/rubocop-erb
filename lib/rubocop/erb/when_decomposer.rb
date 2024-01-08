# frozen_string_literal: true

require 'parser/current'
require 'rubocop/ast/builder'

module RuboCop
  module Erb
    class WhenDecomposer
      REGEXP = /
        \A
        \s*
        when[ \t]
      /x

      class << self
        # @param [RuboCop::Erb::RubyClip] ruby_clip
        # @return [Array<RuboCop::Erb::RubyClip>]
        def call(ruby_clip)
          new(ruby_clip).call
        end
      end

      # @param [RuboCop::Erb::RubyClip] ruby_clip
      def initialize(ruby_clip)
        @ruby_clip = ruby_clip
      end

      # @return [Array<RuboCop::Erb::RubyClip>]
      def call
        match_data = @ruby_clip.code.match(REGEXP)
        if match_data
          offset = match_data[0].length
          parse("[#{@ruby_clip.code[offset..]}]").children.map do |child|
            RubyClip.new(
              code: child.location.expression.source,
              offset: @ruby_clip.offset + offset + child.location.expression.begin_pos - 1
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
        ::Parser::CurrentRuby.new(
          ::RuboCop::AST::Builder.new
        ).parse(
          ::Parser::Source::Buffer.new(
            '(string)',
            source: source
          )
        )
      end
    end
  end
end
