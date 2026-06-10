# frozen_string_literal: true

RSpec.describe RuboCop::Erb::RubyExtractor do
  describe '.call' do
    subject do
      described_class.call(processed_source).first[:processed_source]
    end

    let(:transformed_source) { subject.buffer.source }

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

    context 'with simple source' do
      let(:source)  { '' }

      it 'passes on the parser_engine' do
        next 'Running without passing a parser engine' unless parser_engine

        expect(subject.parser_engine).to eq(parser_engine)
      end
    end

    context 'with multiple inline tags' do
      let(:source) { '<% if true %><%= b %><% end %>' }

      it 'inserts semicolons between the expressions' do
        expect(transformed_source).to eql '   if true  ;    b  ;   end  ;'
        expect(transformed_source.length).to be source.length
      end
    end

    context 'with a comment tag' do
      let(:source) { '<%# a %>' }

      it 'ignores comments' do
        expect(transformed_source).to eql '        '
        expect(transformed_source.length).to be source.length
      end
    end

    context 'with an escape tag' do
      let(:source) { '<%% a %%>' }

      it 'ignores escapes' do
        expect(transformed_source).to eql '       ; '
        expect(transformed_source.length).to be source.length
      end
    end

    context 'with multiple non-Ruby lines' do
      let(:source) do
        <<~ERB
          <div>
            <p>Paragraph</p>
          </div>
        ERB
      end

      let(:expected_source) do
        <<~ERB.tr('_', ' ')
          _____
            ________________
          ______
        ERB
      end

      it 'preserves line breaks' do
        expect(transformed_source).to eql expected_source
        expect(transformed_source.length).to be source.length
        expect(transformed_source.split("\n").map(&:length)).to eql expected_source.split("\n").map(&:length)
      end
    end

    context 'with a multi-byte character in non-Ruby content' do
      let(:source) { '<div>🎉</div><%= foo %>' }

      it 'collapses the blanked multi-byte run so following positions stay aligned' do
        expect(transformed_source).to eql "#{' ' * 16}foo  ;"
        expect(transformed_source.length).to be source.length
        expect(transformed_source.index('foo')).to be source.index('foo')
      end
    end

    context 'with a syntax error' do
      let(:source) { '<% x ' }

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end
  end
end
