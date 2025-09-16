# frozen_string_literal: true

require 'herb'
require 'rubocop'

module RuboCop
  module Erb
    # Extract Ruby codes from Erb template.
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

        ruby_clips.map do |ruby_clip|
          {
            offset: ruby_clip.offset,
            processed_source: ProcessedSourceBuilder.call(
              code: ruby_clip.code,
              processed_source: @processed_source
            )
          }
        end
      end

      private

      # @return [String, nil]
      def file_path
        @processed_source.path
      end

      # @return [Array<Herb::AST::Node>]
      def nodes
        visitor = ErbNodeVisitor.new
        visitor.visit(root)
        visitor.erb_nodes
      end

      # @return [Herb::AST::DocumentNode]
      def root
        ::Herb.parse(template_source).value
      end

      # @return [Array<RuboCop::Erb::RubyClip>]
      def ruby_clips
        nodes.map do |node|
          erb_start_location = node.content.location.start
          line_range = @processed_source.buffer.line_range(erb_start_location.line)
          RubyClip.new(
            code: node.content.value,
            offset: line_range.begin.begin_pos + erb_start_location.column
          )
        end.flat_map do |ruby_clip|
          WhenDecomposer.call(@processed_source, ruby_clip)
        end.map do |ruby_clip|
          KeywordRemover.call(ruby_clip)
        end.reject do |ruby_clip|
          ruby_clip.code.match?(/\A\s*\z/)
        end
      end

      # @return [Boolean]
      def supported_file_path_pattern?
        file_path&.end_with?('.erb')
      end

      # @return [String]
      def template_source
        @processed_source.raw_source
      end

      class ErbNodeVisitor < Herb::Visitor
        # @return [Array<Symbol>]
        def self.erb_visitor_methods
          instance_methods.select { |method_name| method_name.to_s.start_with?('visit_erb_') }
        end

        attr_reader :erb_nodes

        def initialize
          @erb_nodes = []
          super
        end

        # @return [Boolean]
        def comment?(node)
          node.tag_opening.value == '<%#'
        end

        # @return [Boolean]
        def escape?(node)
          node.tag_opening.value == '<%%'
        end

        erb_visitor_methods.each do |method_name|
          class_eval(<<~RUBY, __FILE__, __LINE__ + 1)
            def #{method_name}(node) # def visit_erb_content_node(node)
              record_node(node)      #   record_node(node)
              super                  #   super
            end                      # end
          RUBY
        end

        def record_node(node)
          return if comment?(node) || escape?(node)

          @erb_nodes << node
        end
      end
    end
  end
end
