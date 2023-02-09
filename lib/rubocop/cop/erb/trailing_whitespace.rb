# frozen_string_literal: true

module RuboCop
  module Cop
    module Erb
      # Put one trailing space in a single line ERB.
      #
      # @example
      #   # bad
      #   <% a  %>
      #
      #   # good
      #   <% a %>
      #
      #   # bad
      #   <% a%>
      #
      #   # good
      #   <% a %>
      #
      #   # good
      #   <%
      #     a
      #   %>
      class TrailingWhitespace < Base
        extend AutoCorrector

        MSG = 'Put one trailing space in a single line ERB.'

        # @return [void]
        def on_new_investigation
          return if including_newline? || one_trailing_space?

          range = trailing_whitespace_range
          add_offense(range) do |corrector|
            corrector.replace(range, ' ')
          end
        end

        private

        # @return [Boolean]
        def including_newline?
          processed_source.buffer.source.include?("\n")
        end

        # @return [Boolean]
        def one_trailing_space?
          trailing_whitespace == ' '
        end

        # @return [String]
        def trailing_whitespace
          processed_source.buffer.source[/[ \t]*\z/] || ''
        end

        # @return [Parser::Source::Range]
        def trailing_whitespace_range
          ::Parser::Source::Range.new(
            processed_source.buffer,
            processed_source.raw_source.length - trailing_whitespace.length,
            processed_source.raw_source.length
          )
        end
      end
    end
  end
end
