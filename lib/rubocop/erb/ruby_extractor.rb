# frozen_string_literal: true

require 'better_html'
require 'better_html/parser'
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
            processed_source: ruby_clip_to_processed_source(ruby_clip)
          }
        end
      end

      private

      # @return [Array<BetterHtml::AST::Node>]
      def erbs
        root.descendants(:erb).reject do |node|
          erb_node = ErbNode.new(node)
          erb_node.comment? || erb_node.escape?
        end
      end

      # @return [String, nil]
      def file_path
        @processed_source.path
      end

      # @return [Enumerator<BetterHtml::AST::Node>]
      def nodes
        erbs.flat_map do |erb|
          erb.descendants(:code).to_a
        end
      end

      # @return [BetterHtml::AST::Node]
      def root
        ::BetterHtml::Parser.new(
          ::Parser::Source::Buffer.new(
            @file_path,
            source: template_source
          ),
          template_language: :html
        ).ast
      end

      # @return [RuboCop::ProcessedSource]
      def ruby_clip_to_processed_source(ruby_clip)
        supports_prism = @processed_source.respond_to?(:parser_engine)
        processed_source = if supports_prism
                             ::RuboCop::ProcessedSource.new(
                               ruby_clip.code,
                               @processed_source.ruby_version,
                               file_path,
                               parser_engine: @processed_source.parser_engine
                             )
                           else
                             ::RuboCop::ProcessedSource.new(
                               ruby_clip.code,
                               @processed_source.ruby_version,
                               file_path
                             )
                           end
        processed_source.config = @processed_source.config
        processed_source.registry = @processed_source.registry
        processed_source
      end

      # @return [Array<RuboCop::Erb::RubyClip>]
      def ruby_clips
        nodes.map do |node|
          RubyClip.new(
            code: node.children.first,
            offset: node.location.begin_pos
          )
        end.flat_map do |ruby_clip|
          WhenDecomposer.call(ruby_clip)
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

      class ErbNode
        # @param [BetterHtml::AST::Node] node
        def initialize(node)
          @node = node
        end

        # @return [Boolean]
        def comment?
          indicator == '#'
        end

        # @return [Boolean]
        def escape?
          indicator == '%'
        end

        private

        # @return [BetterHtml::AST::Node, nil]
        def first_child
          @node.children.first
        end

        # @return [String, nil]
        def indicator
          return unless first_child&.type == :indicator

          first_child&.to_a&.first
        end
      end
    end
  end
end
