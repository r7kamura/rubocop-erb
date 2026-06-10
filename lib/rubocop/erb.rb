# frozen_string_literal: true

require 'herb'
require 'rubocop'

module RuboCop
  module Erb
    autoload :ERBSource, 'rubocop/erb/erb_source'
    autoload :RubyExtractor, 'rubocop/erb/ruby_extractor'
  end
end

require_relative 'erb/plugin'
require_relative 'erb/version'
require_relative 'erb/corrector'
