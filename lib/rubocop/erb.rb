# frozen_string_literal: true

module RuboCop
  module Erb
    autoload :ConfigLoader, 'rubocop/erb/config_loader'
    autoload :RubyClip, 'rubocop/erb/ruby_clip'
    autoload :RubyClipper, 'rubocop/erb/ruby_clipper'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
  end
end

require_relative 'erb/rubocop_extension'
require_relative 'erb/version'
