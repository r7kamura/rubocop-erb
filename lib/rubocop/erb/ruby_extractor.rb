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

        nodes.map do |node|
          snippet = node.children.first
          clip = RubyClipper.new(snippet).call
          {
            offset: node.location.begin_pos + clip[:offset],
            processed_source: ::RuboCop::ProcessedSource.new(
              clip[:code],
              @processed_source.ruby_version,
              file_path
            )
          }
        end
      end

      private

      # @return [Array<BetterHtml::AST::Node>]
      def erbs
        root.descendants(:erb).reject do |erb|
          erb.children.first&.type == :indicator && erb.children.first&.to_a&.first == '#'
        end
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
