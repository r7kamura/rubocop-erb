# frozen_string_literal: true

module RuboCop
  module Erb
    autoload :ConfigLoader, 'rubocop/erb/config_loader'
    autoload :KeywordRemover, 'rubocop/erb/keyword_remover'
    autoload :RubyClip, 'rubocop/erb/ruby_clip'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
    autoload :TestHelper, 'rubocop/erb/test_helper'
    autoload :WhenDecomposer, 'rubocop/erb/when_decomposer'
  end
end

require_relative 'erb/rubocop_extension'
require_relative 'erb/version'

require_relative '../rubocop/cop/erb/leading_whitespace'
require_relative '../rubocop/cop/erb/trailing_whitespace'
