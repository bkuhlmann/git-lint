# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Lines::Sentence do
  subject(:reporter) { described_class.new data }

  let(:data) { {number: 1, content: "Example content."} }
  let(:proof) { %(    Line 1: "Example content."\n) }

  describe "#to_s" do
    it "answers label and sentence" do
      expect(reporter.to_s).to eq(proof)
    end
  end

  describe "#to_str" do
    it "answers implicit string" do
      expect(reporter.to_str).to eq(proof)
    end
  end
end
