# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitSubjectPrefix do
  subject(:analyzer) { described_class.new commit }

  include_context "with application dependencies"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commit_subject_prefix")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Prefix")
    end
  end

  describe "#valid?" do
    context "with valid prefix and delimiter" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with invalid delimiter" do
      let(:commit) { Gitt::Models::Commit[subject: "Added: specs"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with no delimiter" do
      let(:commit) { Gitt::Models::Commit[subject: "Addedspecs"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    it "answers true with custom include list" do
      analyzer = described_class.new(
        Gitt::Models::Commit[subject: "One test"],
        configuration: configuration.with(commits_subject_prefix_includes: %w[One Two])
      )

      expect(analyzer.valid?).to be(true)
    end

    it "answers true with empty include list" do
      analyzer = described_class.new(
        Gitt::Models::Commit[subject: "Test"],
        configuration: configuration.with(commits_subject_prefix_includes: [])
      )

      expect(analyzer.valid?).to be(true)
    end

    it "answers true with custom delimiter" do
      analyzer = described_class.new(
        Gitt::Models::Commit[subject: "Added - specs"],
        configuration: configuration.with(
          commits_subject_prefix_delimiter: " - ",
          commits_subject_prefix_includes: ["Added"]
        )
      )

      expect(analyzer.valid?).to be(true)
    end

    context "with amend" do
      let(:commit) { Gitt::Models::Commit[subject: "amend! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with amend in CI" do
      let(:commit) { Gitt::Models::Commit[subject: "amend! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with fixup" do
      let(:commit) { Gitt::Models::Commit[subject: "fixup! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with fixup in CI" do
      let(:commit) { Gitt::Models::Commit[subject: "fixup! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with squash" do
      let(:commit) { Gitt::Models::Commit[subject: "squash! Added specs"] }

      it "answers true" do
        expect(analyzer.valid?).to be(true)
      end
    end

    context "with squash in CI" do
      let(:commit) { Gitt::Models::Commit[subject: "squash! Added specs"] }
      let(:environment) { {"CI" => "true"} }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end

    context "with invalid prefix" do
      let(:commit) { Gitt::Models::Commit[subject: "Bogus"] }

      it "answers false" do
        expect(analyzer.valid?).to be(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { Gitt::Models::Commit[subject: "Added specs"] }

      it "answers empty string" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[subject: "Bogus"] }

      it "answres issue hint" do
        expect(issue[:hint]).to eq(
          "Use: /Fixed /, /Added /, /Updated /, /Removed /, /Refactored /."
        )
      end
    end
  end
end
