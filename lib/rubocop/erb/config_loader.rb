# frozen_string_literal: true

require 'rubocop'

module RuboCop
  module Erb
    # Merge default RuboCop config with plugin config.
    class ConfigLoader
      PLUGIN_CONFIG_PATH = ::File.expand_path(
        '../../../config/default.yml',
        __dir__
      )

      class << self
        # @return [RuboCop::Config]
        def call
          new.call
        end
      end

      # @return [RuboCop::Config]
      def call
        RuboCop::ConfigLoader.merge_with_default(
          plugin_config,
          PLUGIN_CONFIG_PATH
        )
      end

      private

      # @return [RuboCop::Config]
      def plugin_config
        config = ::RuboCop::Config.new(
          plugin_config_hash,
          PLUGIN_CONFIG_PATH
        )
        config.make_excludes_absolute
        config
      end

      # @return [Hash]
      def plugin_config_hash
        ::RuboCop::ConfigLoader.send(
          :load_yaml_configuration,
          PLUGIN_CONFIG_PATH
        )
      end
    end
  end
end
