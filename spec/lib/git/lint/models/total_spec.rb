# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Models::Total do
  subject(:total) { described_class.new }

  describe "#initialize" do
    it "answers zero for all defaults" do
      expect(total).to have_attributes(items: 0, issues: 0, warnings: 0, errors: 0)
    end
  end

  describe "#empty?" do
    it "answers true when zero" do
      expect(total.empty?).to be(true)
    end

    it "answers false when not zero" do
      expect(total.with(items: 1).empty?).to be(false)
    end
  end

  describe "#issues?" do
    it "answers true when not zero" do
      expect(total.with(issues: 1).issues?).to be(true)
    end

    it "answers false when zero" do
      expect(total.issues?).to be(false)
    end
  end

  describe "#warnings?" do
    it "answers true when not zero" do
      expect(total.with(warnings: 1).warnings?).to be(true)
    end

    it "answers false when zero" do
      expect(total.warnings?).to be(false)
    end
  end

  describe "#errors?" do
    it "answers true when not zero" do
      expect(total.with(errors: 1).errors?).to be(true)
    end

    it "answers false when zero" do
      expect(total.errors?).to be(false)
    end
  end
end
