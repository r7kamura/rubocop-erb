# frozen_string_literal: true

module RuboCop
  module Erb
    autoload :ConfigLoader, 'rubocop/erb/config_loader'
    autoload :KeywordRemover, 'rubocop/erb/keyword_remover'
    autoload :RubyClip, 'rubocop/erb/ruby_clip'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
    autoload :WhenDecomposer, 'rubocop/erb/when_decomposer'
  end
end

require_relative 'erb/rubocop_extension'
require_relative 'erb/version'
