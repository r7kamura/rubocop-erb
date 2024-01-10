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
        <%- end %>
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

    context 'with `when a, b`' do
      let(:source) do
        <<~ERB
          <% when a, b %>
        ERB
      end

      it 'returns Ruby codes for a and b' do
        result = subject
        expect(result.length).to eq(2)
        expect(result[0][:processed_source].raw_source).to eq('a')
        expect(result[0][:offset]).to eq(8)
        expect(result[1][:processed_source].raw_source).to eq('b')
        expect(result[1][:offset]).to eq(11)
      end
    end

    context 'with `else`' do
      let(:source) do
        <<~ERB
          <% else %>
        ERB
      end

      it 'returns Ruby codes for a and b' do
        result = subject
        expect(result).to be_empty
      end
    end

    context 'with `<%# a %>`' do
      let(:source) do
        <<~ERB
          <%# a %>
        ERB
      end

      it 'ignores comments' do
        result = subject
        expect(result).to be_empty
      end
    end

    context 'with `<%% a %%>`' do
      let(:source) do
        <<~ERB
          <%% a %%>
        ERB
      end

      it 'ignores escapes' do
        result = subject
        expect(result).to be_empty
      end
    end

    context 'with braces' do
      let(:source) do
        <<~ERB
          <%= foo.each { |a, b| %>
            <br>
          <% } %>
        ERB
      end

      it 'ignores both opening and closing braces' do
        result = subject
        expect(result.length).to eq(1)
        expect(result[0][:processed_source].raw_source).to eq(' foo.each ')
        expect(result[0][:offset]).to eq(3)
      end
    end

    context 'with trailing `then`' do
      let(:source) do
        <<~ERB
          <%= if foo then %>
        ERB
      end

      it 'ignores `then`' do
        result = subject
        expect(result.length).to eq(1)
        expect(result[0][:processed_source].raw_source).to eq('foo')
        expect(result[0][:offset]).to eq(7)
      end
    end

    context 'with trailing newline after `do`' do
      let(:source) do
        <<~ERB
          <% foo.each do
           %>
        ERB
      end

      it 'ignores `do`' do
        result = subject
        expect(result.length).to eq(1)
        expect(result[0][:processed_source].raw_source).to eq(' foo.each')
        expect(result[0][:offset]).to eq(2)
      end
    end
  end
end
