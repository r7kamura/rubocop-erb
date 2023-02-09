# frozen_string_literal: true

module RuboCop
  module Cop
    module Erb
      # Put one leading space in a single line ERB.
      #
      # @example
      #   # bad
      #   <%  a %>
      #
      #   # good
      #   <% a %>
      #
      #   # bad
      #   <%a %>
      #
      #   # good
      #   <% a %>
      #
      #   # good
      #   <%
      #     a
      #   %>
      class LeadingWhitespace < Base
        extend AutoCorrector

        MSG = 'Put one leading space in a single line ERB.'

        # @return [void]
        def on_new_investigation
          return if including_newline? || one_leading_space?

          range = leading_whitespace_range
          add_offense(range) do |corrector|
            corrector.replace(range, ' ')
          end
        end

        private

        # @return [Boolean]
        def including_newline?
          processed_source.buffer.source.include?("\n")
        end

        # @return [String]
        def leading_whitespace
          processed_source.buffer.source[/\A[ \t]*/] || ''
        end

        # @return [Parser::Source::Range]
        def leading_whitespace_range
          ::Parser::Source::Range.new(
            processed_source.buffer,
            0,
            leading_whitespace.length
          )
        end

        # @return [Boolean]
        def one_leading_space?
          leading_whitespace == ' '
        end
      end
    end
  end
end
