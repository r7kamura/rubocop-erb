# frozen_string_literal: true

module RuboCop
  module Erb
    class ERBSource < ProcessedSource
      attr_reader :herb_parse_result, :template_source

      def initialize(
        template_source,
        ...
      )
        @template_source = template_source
        @herb_parse_result = Herb.parse(template_source)

        super(...)
      end

      # @param [Integer] byte_offset offset into the (original) source in bytes
      # @return [Integer] the equivalent character offset
      def byte_to_char_offset(byte_offset)
        template_source.byteslice(0, byte_offset).length
      end

      # @param [Integer] position full position in the buffer
      # @return [Herb::AST::Node, nil] the ERB node whose tag contains the position
      def erb_node_for_pos(position)
        erb_node_offsets.bsearch do |(range, _node)|
          next -1 if position < range.begin
          next 1 if position >= range.end

          0
        end&.last
      end

      # Buffer ranges of every ERB tag (`<% … %>`), paired with their node.
      #
      # @return [Array<(Range, Herb::AST::Node)>]
      def erb_node_offsets
        @erb_node_offsets ||= [].tap { |offsets| ERBNodeOffsetVisitor.new(self, offsets).visit(erb_root) }
      end

      # @return [Herb::AST::DocumentNode]
      def erb_root
        herb_parse_result.value
      end

      # @param [Herb::Location] location
      # @return [Parser::Source::Range]
      def herb_location_to_parser_range(location)
        Parser::Source::Range.new(buffer,
                                  herb_position_to_buffer_pos(location.start),
                                  herb_position_to_buffer_pos(location.end))
      end

      # @param [Herb::Position] position
      # @return [Integer]
      def herb_position_to_buffer_pos(position)
        line_range = buffer.line_range(position.line)
        # Herb reports columns as byte offsets, but the parser buffer uses
        # character offsets; convert so multi-byte characters line up.
        char_column = line_range.source.byteslice(0, position.column).length
        line_range.begin.begin_pos + char_column
      end

      # @param [Herb::Position] position
      # @return [Parser::Source::Range] zero-width range at the position
      def herb_position_to_parser_range(position)
        pos = herb_position_to_buffer_pos(position)
        Parser::Source::Range.new(buffer, pos, pos)
      end

      # @param [Herb::Range] range
      # @return [Parser::Source::Range]
      def herb_range_to_parser_range(range)
        # Herb ranges are byte offsets into the source; the parser buffer uses
        # character offsets, so convert to keep multi-byte characters aligned.
        Parser::Source::Range.new(buffer, byte_to_char_offset(range.from), byte_to_char_offset(range.to))
      end

      # @return [Boolean] whether the buffer range lies entirely within the Ruby
      #   content (between the delimiters) of a single ERB tag
      def range_within_ruby_content?(
        begin_pos,
        end_pos
      )
        return false unless (node = erb_node_for_pos(begin_pos)) && (content = node.content)

        begin_pos >= herb_position_to_buffer_pos(content.location.start) &&
          end_pos <= herb_position_to_buffer_pos(content.location.end)
      end

      # Convert various Herb node or range types to a Parser::Source::Range
      # Unrecognized values are passed through
      #
      # @param [#range, #location, Herb::Location, Herb::Range, Object] node_or_range
      # @return [Parser::Source::Range, Object, nil]
      def to_range(node_or_range)
        node_or_range = node_or_range.range if node_or_range.respond_to?(:range)
        if node_or_range.is_a?(Herb::AST::Node) || node_or_range.is_a?(Herb::Token)
          node_or_range = node_or_range.location
        end
        node_or_range = herb_location_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Location)
        node_or_range = herb_range_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Range)
        node_or_range = herb_position_to_parser_range(node_or_range) if node_or_range.is_a?(Herb::Position)

        node_or_range
      end

      # Collects the buffer range of every ERB tag, paired with its node.
      class ERBNodeOffsetVisitor < Herb::Visitor
        def initialize(
          source,
          offsets
        )
          @source = source
          @offsets = offsets
          super()
        end

        def visit_erb_node(node)
          @offsets << [
            Range.new(@source.herb_position_to_buffer_pos(node.tag_opening.location.start),
                      @source.herb_position_to_buffer_pos(node.tag_closing.location.end),
                      true),
            node
          ]
          super
        end
      end
      private_constant :ERBNodeOffsetVisitor
    end
  end
end
