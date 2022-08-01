# frozen_string_literal: true

RSpec.describe RuboCop::Erb::RubyExtractor do
  describe '.call' do
    subject do
      described_class.call(processed_source)
    end

    let(:processed_source) do
      RuboCop::ProcessedSource.new(
        source,
        3.1,
        file_path
      )
    end

    let(:file_path) do
      'dummy.erb'
    end

    let(:source) do
      <<~ERB
        <% "a" %>
        <%= b %>
        <% a = 1 %>
      ERB
    end

    context 'with valid condition' do
      it 'returns Ruby codes with offset' do
        result = subject
        expect(result.length).to eq(3)
        expect(result[0][:processed_source].raw_source).to eq(' "a" ')
        expect(result[0][:offset]).to eq(2)
        expect(result[0][:processed_source].file_path).to eq(file_path)
        expect(result[1][:processed_source].raw_source).to eq(' b ')
        expect(result[1][:offset]).to eq(13)
        expect(result[2][:processed_source].raw_source).to eq(' a = 1 ')
        expect(result[2][:offset]).to eq(21)
      end
    end
  end
end
