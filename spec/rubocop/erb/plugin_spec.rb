# frozen_string_literal: true

require 'rubocop'
require 'yaml'

RSpec.describe RuboCop::Erb::Plugin do
  describe 'config/default.yml' do
    it 'only configures cops that exist' do
      config = YAML.safe_load_file(File.expand_path('../../../config/default.yml', __dir__))
      cop_names = config.keys - %w[inherit_mode AllCops]

      expect(cop_names.reject { |name| RuboCop::Cop::Registry.global.find_by_cop_name(name) }).to be_empty
    end
  end
end
