# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Lines::Paragraph do
  subject(:reporter) { described_class.new data }

  let(:data) { {number: 1, content: "One.\nTwo.\nThree."} }

  let(:proof) { %(    Line 1: "One.\n) + %(             Two.\n) + %(             Three."\n) }

  describe "#to_s" do
    it "answers label and paragraph" do
      expect(reporter.to_s).to eq(proof)
    end
  end

  describe "#to_str" do
    it "answers implicit string" do
      expect(reporter.to_str).to eq(proof)
    end
  end
end
