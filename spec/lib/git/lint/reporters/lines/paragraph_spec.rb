# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Lines::Paragraph do
  subject(:paragraph) { described_class.new data }

  let(:data) { {number: 1, content: "One.\nTwo.\nThree."} }

  describe "#to_s" do
    it "answers label and paragraph" do
      expect(paragraph.to_s).to eq(
        %(    Line 1: "One.\n) +
        %(             Two.\n) +
        %(             Three."\n)
      )
    end
  end
end
