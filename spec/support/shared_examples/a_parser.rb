# frozen_string_literal: true

RSpec.shared_examples_for "a parser" do
  describe ".call" do
    it "answers configuration" do
      parser = described_class.call client: OptionParser.new
      expect(parser).to be_a(Git::Lint::Configuration::Content)
    end
  end
end
