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
          processed_source = ::RuboCop::ProcessedSource.new(
            ruby_clip.code,
            @processed_source.ruby_version,
            file_path
          )
          processed_source.config = @processed_source.config
          processed_source.registry = @processed_source.registry
          {
            offset: ruby_clip.offset,
            processed_source: processed_source
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
          RubyClipper.call(ruby_clip)
        end.reject do |ruby_clip|
          ruby_clip.code.match?(/\A\s*\z/)
        end
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
