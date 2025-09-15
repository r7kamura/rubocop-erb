# frozen_string_literal: true

module RuboCop
  module Erb
    # Remove unnecessary keyword part (e.g. `if`, `unless`, `do`, ...) from Ruby-ish code.
    class KeywordRemover
      class << self
        # @param [RuboCop::Erb::RubyClip] ruby_clip
        # @return [RuboCop::Erb::RubyClip]
        def call(ruby_clip)
          new(ruby_clip).call
        end
      end

      # @param [RuboCop::Erb::RubyClip] ruby_clip
      def initialize(ruby_clip)
        @ruby_clip = ruby_clip
      end

      # @return [RuboCop::Erb::RubyClip]
      def call
        [
          PrecedingKeywordRemover,
          PrecedingBraceRemover,
          TrailingBraceRemover,
          TrailingThenRemover,
          TrailingDoRemover
        ].reduce(@ruby_clip) do |previous, callable|
          result = callable.call(previous.code)
          RubyClip.new(
            code: result.code,
            offset: previous.offset + result.offset
          )
        end
      end

      class PrecedingSourceRemover
        class << self
          # @param [String] code
          # @return [RubyClip]
          def call(code)
            new(code).call
          end
        end

        # @param [String] code
        def initialize(code)
          @code = code
        end

        # @return [Hash]
        def call
          data = @code.match(self.class::REGEXP)
          if data
            offset = data[0].length
            RubyClip.new(
              code: @code[offset..],
              offset: offset
            )
          else
            RubyClip.new(
              code: @code,
              offset: 0
            )
          end
        end
      end

      # Remove preceding keyword.
      class PrecedingKeywordRemover < PrecedingSourceRemover
        REGEXP = /
          \A
          \s*
          (?:
            begin
            | case
            | else
            | elsif
            | end
            | ensure
            | if
            | rescue
            | unless
            | until
            | when
            | while
            | for[ \t]+\w+[ \t]+in
          )
          \b[ \t]*
        /x
      end

      # Remove preceding `}`.
      class PrecedingBraceRemover < PrecedingSourceRemover
        REGEXP = /
          \A
          \s*
          }
        /x
      end

      class TrailingSourceRemover
        class << self
          # @param [String] code
          # @return [RubyClip]
          def call(code)
            new(code).call
          end
        end

        # @param [String] code
        def initialize(code)
          @code = code
        end

        # @return [Hash]
        def call
          RubyClip.new(
            code: @code.sub(self.class::REGEXP, ''),
            offset: 0
          )
        end
      end

      # Remove trailing `{`.
      class TrailingBraceRemover < TrailingSourceRemover
        REGEXP = /
          {
          [ \t]*
          (?:\|[^|]*\|)?
          \s*
          \z
        /x
      end

      # Remove trailing `then`.
      class TrailingThenRemover < TrailingSourceRemover
        REGEXP = /
          [ \t]*\b
          then
          \s*
          \z
        /x
      end

      # Remove trailing `do`.
      class TrailingDoRemover < TrailingSourceRemover
        REGEXP = /
          (?:\b[ \t]*|[ \t])
          do
          [ \t]*
          (?:\|[^|]*\|)?
          \s*
          (\#.*)?
          \z
        /x
      end
    end
  end
end
