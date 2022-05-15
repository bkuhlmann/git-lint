# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectPrefix do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_subject_prefix)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Prefix")
    end
  end

  describe "#valid?" do
    context "with valid prefix and delimiter" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid delimiter" do
      let(:commit) { GitPlus::Commit[subject: "Added: specs"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with no delimiter" do
      let(:commit) { GitPlus::Commit[subject: "Addedspecs"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with custom include list" do
      subject(:analyzer) { described_class.new GitPlus::Commit[subject: "One"] }

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_subject_prefix, includes: %w[One Two]]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with empty include list" do
      subject(:analyzer) { described_class.new GitPlus::Commit[subject: "Test"] }

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[id: :commit_subject_prefix, includes: []]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with custom delimiter" do
      let(:commit) { GitPlus::Commit[subject: "Added - specs"] }

      let :configuration do
        Git::Lint::Configuration::Content[
          analyzers: [
            Git::Lint::Configuration::Setting[
              id: :commit_subject_prefix,
              includes: ["Added"],
              delimiter: " - "
            ]
          ]
        ]
      end

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with amend" do
      let(:commit) { GitPlus::Commit[subject: "amend! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with amend in CI" do
      let(:commit) { GitPlus::Commit[subject: "amend! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with fixup" do
      let(:commit) { GitPlus::Commit[subject: "fixup! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with fixup in CI" do
      let(:commit) { GitPlus::Commit[subject: "fixup! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with squash" do
      let(:commit) { GitPlus::Commit[subject: "squash! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with squash in CI" do
      let(:commit) { GitPlus::Commit[subject: "squash! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with invalid prefix" do
      let(:commit) { GitPlus::Commit[subject: "Bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[subject: "Added specs"] }

      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { GitPlus::Commit[subject: "Bogus"] }

      it "answres issue hint" do
        expect(issue[:hint]).to eq(
          "Use: /Fixed /, /Added /, /Updated /, /Removed /, /Refactored /."
        )
      end
    end
  end
end
