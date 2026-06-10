# frozen_string_literal: true

RSpec.describe RuboCop::Erb::Corrector do
  # A non-ERB-department cop whose corrections would otherwise be discarded when
  # they touch non-Ruby content.
  let(:cop) do
    RuboCop::Cop::Layout::CaseIndentation.new(RuboCop::Config.new).tap do |cop|
      cop.instance_variable_set(:@processed_source, erb_source)
    end
  end

  let(:corrector) { RuboCop::Cop::Corrector.new(cop) }

  let(:erb_source) do
    processed_source = RuboCop::ProcessedSource.new(source, 3.1, 'dummy.html.erb')
    RuboCop::Erb::RubyExtractor.call(processed_source).first[:processed_source]
  end

  let(:source) { "<% case x %>\n      <% when 1 %>\n<% end %>\n" }

  # The whitespace + opening tag (`<% `) on line 2, from line start through the
  # `when` keyword -- the range Layout/CaseIndentation hands the corrector.
  let(:range) do
    line = erb_source.buffer.line_range(2)
    Parser::Source::Range.new(erb_source.buffer, line.begin_pos, line.begin_pos + 9)
  end

  describe '#whitespace_indent_adjustment (reshaping a correction that crosses into a tag)' do
    subject(:adjustment) { corrector.send(:whitespace_indent_adjustment, range, attributes) }

    context 'with a whitespace replacement that reaches into the opening tag' do
      let(:attributes) { { replacement: ' ' * 6 } }

      it 'shrinks the range to the leading whitespace and preserves the tag' do
        new_range, new_attributes = adjustment
        tag_start = erb_source.buffer.line_range(2).begin_pos + 6

        # The reshaped range stops at the `<%`, so the tag is never overwritten.
        expect(new_range.end_pos).to eq(tag_start)
        # The replacement is reduced by the preserved `<% ` prefix (3 chars).
        expect(new_attributes[:replacement]).to eq('   ')
      end
    end

    context 'with a non-whitespace replacement' do
      let(:attributes) { { replacement: 'x' * 6 } }

      it 'returns nil so the correction is not treated as a benign re-indent' do
        expect(adjustment).to be_nil
      end
    end

    context 'when the attributes hash has none of the expected content keys' do
      let(:attributes) { {} }

      it 'fails safe and returns nil rather than assuming whitespace-only' do
        expect(adjustment).to be_nil
      end
    end
  end
end
