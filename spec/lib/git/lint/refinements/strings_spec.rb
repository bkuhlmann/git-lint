# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Refinements::Strings do
  using described_class

  describe ".pluralize" do
    context "with default suffix" do
      subject(:issue) { "issue" }

      it "pluralizes zero count" do
        expect(issue.pluralize(count: 0)).to eq("0 issues")
      end

      it "pluralizes count greater than one" do
        expect(issue.pluralize(count: 2)).to eq("2 issues")
      end

      it "does not pluralize count of one" do
        expect(issue.pluralize(count: 1)).to eq("1 issue")
      end
    end

    context "with custom suffix" do
      subject(:branch) { "branch" }

      it "pluralizes zero count" do
        expect(branch.pluralize(count: 0, suffix: "es")).to eq("0 branches")
      end

      it "pluralizes count greater than one" do
        expect(branch.pluralize(count: 2, suffix: "es")).to eq("2 branches")
      end

      it "does not pluralize one count" do
        expect(branch.pluralize(count: 1)).to eq("1 branch")
      end
    end
  end

  describe "#fixup?" do
    it "answers true when fixup! prefix is included" do
      expect("fixup! Added test file.".fixup?).to eq(true)
    end

    it "answers false when fixup! prefix is excluded" do
      expect("Added test file.".fixup?).to eq(false)
    end

    it "answers false when fixup! prefix is missing trailing space" do
      expect("fixup!Added test file.".fixup?).to eq(false)
    end

    it "answers false when fixup! is not a prefix" do
      expect(" fixup! Added test file.".fixup?).to eq(false)
    end
  end

  describe "#squash?" do
    it "answers true when squash! prefix is included" do
      expect("squash! Added test file.".squash?).to eq(true)
    end

    it "answers false when squash! prefix is excluded" do
      expect("Added test file.".squash?).to eq(false)
    end

    it "answers false when squash! prefix is missing trailing space" do
      expect("squash!Added test file.".squash?).to eq(false)
    end

    it "answers false when squash! is not a prefix" do
      expect(" squash! Added test file.".squash?).to eq(false)
    end
  end
end
