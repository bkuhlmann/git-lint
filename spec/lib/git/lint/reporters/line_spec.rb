# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Line do
  subject(:reporter) { described_class.new line }

  describe "#to_s" do
    context "with sentence" do
      let(:line) { {number: 1, content: "Example."} }

      it "answers non-indented content" do
        expect(reporter.to_s).to eq(%(    Line 1: "Example."\n))
      end
    end

    context "with paragraph" do
      let(:line) { {number: 1, content: "One.\nTwo.\nThree."} }

      it "answers indented multi-line content" do
        expect(reporter.to_s).to eq(
          %(    Line 1: "One.\n) +
          %(             Two.\n) +
          %(             Three."\n)
        )
      end
    end
  end

  describe "#to_str" do
    let(:line) { {number: 1, content: "Example."} }

    it "answers implicit string" do
      expect(reporter.to_str).to eq(%(    Line 1: "Example."\n))
    end
  end
end
