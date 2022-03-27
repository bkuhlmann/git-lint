# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Parsers::Analyze do
  subject(:parser) { described_class.new configuration.dup }

  include_context "with application dependencies"

  it_behaves_like "a parser"

  describe "#call" do
    it "answers SHA" do
      expect(parser.call(%w[--sha abc])).to have_attributes(analyze_sha: "abc")
    end

    it "fails with missing arguments" do
      result = proc { parser.call %w[--sha] }
      expect(&result).to raise_error(OptionParser::MissingArgument, /--sha/)
    end
  end
end
