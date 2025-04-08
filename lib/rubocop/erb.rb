# frozen_string_literal: true

module RuboCop
  module Erb
    autoload :KeywordRemover, 'rubocop/erb/keyword_remover'
    autoload :ProcessedSourceBuilder, 'rubocop/erb/processed_source_builder'
    autoload :RubyClip, 'rubocop/erb/ruby_clip'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
    autoload :WhenDecomposer, 'rubocop/erb/when_decomposer'
  end
end

require_relative 'erb/plugin'
require_relative 'erb/version'
