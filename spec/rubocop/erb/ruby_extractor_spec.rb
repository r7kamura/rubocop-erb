# frozen_string_literal: true

RSpec.describe RuboCop::Erb::RubyExtractor do
  describe '.call' do
    subject do
      described_class.call(processed_source)
    end

    let(:parser_engine) do
      env_value = ENV.fetch('PARSER_ENGINE', nil)
      env_value == '' ? nil : env_value&.to_sym
    end

    let(:processed_source) do
      if parser_engine
        RuboCop::ProcessedSource.new(
          source,
          3.3,
          file_path,
          parser_engine: parser_engine
        )
      else
        RuboCop::ProcessedSource.new(
          source,
          3.1,
          file_path
        )
      end
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

      it 'passes on the parser_engine' do
        next 'Running without passing a parser engine' unless parser_engine

        result = subject
        expect(result[0][:processed_source].parser_engine).to eq(parser_engine)
        expect(result[1][:processed_source].parser_engine).to eq(parser_engine)
        expect(result[2][:processed_source].parser_engine).to eq(parser_engine)
      end
    end

    context 'with `foo(bar)do`' do
      let(:source) do
        <<~ERB
          <% foo(bar)do %>
        ERB
      end

      it 'returns `foo(bar)` part' do
        result = subject
        expect(result.length).to eq(1)
        expect(result[0][:processed_source].raw_source).to eq(' foo(bar)')
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

    context 'with `when` closing on different line' do
      let(:source) do
        <<~ERB
          <% when foo
            @bar = baz
          %>
        ERB
      end

      it 'ignores the code' do
        result = subject
        expect(result).to be_empty
      end
    end

    context 'with `else`' do
      let(:source) do
        <<~ERB
          <% else %>
        ERB
      end

      it 'ignores the code' do
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

    context 'with a syntax error' do
      let(:source) do
        <<~ERB
          <% h!.2 %>
          <% "foo" %>
        ERB
      end

      it 'ignores the clip' do
        result = subject
        expect(result.length).to eq(1)
        expect(result[0][:processed_source].raw_source).to eq(' "foo" ')
        expect(result[0][:offset]).to eq(13)
      end
    end
  end
end
