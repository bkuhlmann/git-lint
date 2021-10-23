# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Parsers::Analyze do
  subject(:parser) { described_class.new configuration.dup }

  include_context "with application container"

  it_behaves_like "a parser"

  describe "#call" do
    it "answers SHAs when given array" do
      expect(parser.call(%w[--shas abc,def])).to have_attributes(analyze_shas: %w[abc def])
    end

    it "fails with missing arguments" do
      result = proc { parser.call %w[--shas] }
      expect(&result).to raise_error(OptionParser::MissingArgument, /--shas/)
    end
  end
end
