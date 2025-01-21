# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzer do
  using Refinements::Struct

  subject(:analyzer) { described_class.new }

  include_context "with Git commit"

  describe "#call" do
    let :proof do
      [
        Tone.new,
        [
          "Running Git Lint...\n\n" \
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): Added documentation\n"
        ],
        ["  Commit Body Leading Line Warning. Use blank line between subject and body.\n", :yellow],
        ["\n1 commit inspected. "],
        ["1 issue", :yellow],
        [" detected ("],
        ["1 warning", :yellow],
        [", "],
        ["0 errors", :green],
        [").\n"]
      ]
    end

    it "reports issues with zero items for invalid commits" do
      reporter = analyzer.call [git_commit.with(body_lines: ["Test."])]
      expect(reporter.to_s).to have_color(proof)
    end

    it "answers reporter" do
      expect(analyzer.call).to be_a(Git::Lint::Reporters::Branch)
    end
  end
end
