# frozen_string_literal: true

RSpec.describe RuboCop::Erb::ERBSource do
  subject(:erb_source) do
    processed_source = RuboCop::ProcessedSource.new(source, 3.1, filename)
    RuboCop::Erb::RubyExtractor.call(processed_source).first[:processed_source]
  end

  let(:filename) { 'dummy.html.erb' }

  describe '#herb_position_to_buffer_pos' do
    let(:source) { 'café<%= x %>' }

    it 'returns a character offset, accounting for multi-byte characters in the line' do
      _range, node = erb_source.erb_node_offsets.first

      # `<%=` begins after the 4-character (5-byte) "café"; Herb reports a byte
      # column, so a naive conversion would land at 5.
      expect(erb_source.herb_position_to_buffer_pos(node.tag_opening.location.start))
        .to eq(source.index('<%='))
    end
  end

  describe '#range_within_ruby_content?' do
    let(:source) { '<%= foo %>' }

    it 'is true for a range entirely inside the tag content' do
      start = source.index('foo')
      expect(erb_source.range_within_ruby_content?(start, start + 3)).to be(true)
    end

    it 'is false for a range that covers the opening delimiter' do
      expect(erb_source.range_within_ruby_content?(0, 3)).to be(false)
    end
  end
end
