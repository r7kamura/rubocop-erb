# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Erb::TrailingWhitespace, :config do
  context 'when trailing spaces count is 1' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY, 'example.erb')
        <% a %>
      RUBY
    end
  end

  context 'when trailing spaces count is 2 in multiline ERB' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY, 'example.erb')
        <%
          a
        %>
      RUBY
    end
  end

  context 'when trailing spaces count is 2' do
    it 'registers offense' do
      expect_offense(<<~RUBY, 'example.erb')
        <% a  %>
            ^^ Put one trailing space in a single line ERB.
      RUBY

      expect_correction(<<~RUBY)
        <% a %>
      RUBY
    end
  end

  context 'when trailing spaces count is 0' do
    it 'registers offense' do
      expect_offense(<<~RUBY, 'example.erb')
        <% a%>
            ^{} Put one trailing space in a single line ERB.
      RUBY

      expect_correction(<<~RUBY)
        <% a %>
      RUBY
    end
  end
end
