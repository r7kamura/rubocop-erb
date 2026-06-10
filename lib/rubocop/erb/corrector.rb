# frozen_string_literal: true

module RuboCop
  module Erb
    module Corrector
      def initialize(source)
        @processed_source = source.processed_source if source.respond_to?(:processed_source)
        @discard_non_ruby_corrections = @processed_source.is_a?(ERBSource)
        super
      end

      # Every rewrite operation funnels through `combine`, which is the only place
      # both the target range and the replacement text are available. We use it to
      # recognize a benign re-indentation -- only adding or removing whitespace in
      # the leading whitespace of a line that begins with an ERB tag -- so it is
      # kept rather than discarded as a non-Ruby correction. When the correction
      # reaches past the indentation into the opening tag itself (as
      # `Layout/CaseIndentation` does), it is shrunk to cover only the leading
      # whitespace so the tag is preserved.
      def combine(
        range,
        attributes
      )
        if (adjustment = whitespace_indent_adjustment(range, attributes))
          range, attributes = adjustment
          @whitespace_only_indent = true
        end
        super
      ensure
        @whitespace_only_indent = false
      end

      # A correction that touches non-Ruby code can't be applied to the extracted
      # Ruby without breaking the surrounding ERB. Rather than apply a broken fix,
      # we discard the whole correction (every operation from the offense) by
      # reporting the corrector as empty, leaving the offense flagged but not
      # auto-correctable.
      def empty?
        return true if @intersects_non_ruby

        super
      end

      def to_range(node_or_range)
        node_or_range = @processed_source.to_range(node_or_range) if @processed_source.is_a?(ERBSource)
        range = super
        flag_non_ruby_intersection(range)
        range
      end

      private

      def flag_non_ruby_intersection(range)
        return unless @discard_non_ruby_corrections
        return unless @processed_source.is_a?(ERBSource)
        return unless range.is_a?(::Parser::Source::Range)
        return if @whitespace_only_indent
        return if @processed_source.range_within_ruby_content?(range.begin_pos, range.end_pos)

        @intersects_non_ruby = true
      end

      # @return [Array(Parser::Source::Range, Hash), nil] the (possibly rewritten)
      #   range and attributes to apply when the operation only adjusts whitespace
      #   in the leading indentation of an ERB-tag line, or nil when inapplicable
      def whitespace_indent_adjustment(
        range,
        attributes
      )
        return unless @discard_non_ruby_corrections && @processed_source.is_a?(ERBSource)
        return unless range.is_a?(::Parser::Source::Range)
        return unless attributes.is_a?(Hash)

        replacement = attributes[:replacement]
        contents = attributes.values_at(:replacement, :insert_before, :insert_after).compact
        # `attributes` comes from Parser's TreeRewriter internals. If none of the
        # content keys we know about are present, the shape has changed from under
        # us -- fail safe by treating this as a normal correction (discarded if it
        # touches non-Ruby) rather than assuming it is whitespace-only.
        return if contents.empty?
        return unless contents.all? { |content| content.match?(/\A\s*\z/) }

        source = @processed_source.template_source
        line = @processed_source.buffer.line_range(@processed_source.buffer.line_for_position(range.begin_pos))
        offset = source[line.begin_pos...line.end_pos].to_s.index(/\S/)
        return unless offset

        tag_start = line.begin_pos + offset
        # Everything from the line start up to the range, and the first code on the
        # line, must be whitespace then an ERB opening tag.
        return unless source[tag_start, 2] == '<%'
        return unless source[line.begin_pos...range.begin_pos].to_s.match?(/\A\s*\z/)
        return unless range.begin_pos <= tag_start

        # Wholly within the indentation: keep the operation untouched.
        return [range, attributes] if range.end_pos <= tag_start

        # The range crosses into the tag; only the opening delimiter and trailing
        # whitespace may be swallowed, and only a replacement can be reshaped.
        return unless replacement

        preserved = source[tag_start...range.end_pos].to_s
        return unless preserved.match?(/\A<%[-=]*\s*\z/)

        new_length = replacement.length - preserved.length
        return if new_length.negative?

        new_range = ::Parser::Source::Range.new(range.source_buffer, range.begin_pos, tag_start)
        [new_range, attributes.merge(replacement: ' ' * new_length)]
      end
    end
    Cop::Corrector.prepend(Corrector)
  end
end
