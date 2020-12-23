# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::CommitBodyIssueTrackerLink do
  subject(:analyzer) { described_class.new commit: commit }

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq(:commit_body_issue_tracker_link)
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Body Issue Tracker Link")
    end
  end

  describe ".defaults" do
    it "answers defaults" do
      expect(described_class.defaults).to eq(
        enabled: true,
        severity: :error,
        excludes: [
          "(f|F)ix(es|ed)?\\s\\#\\d+",
          "(c|C)lose(s|d)?\\s\\#\\d+",
          "(r|R)esolve(s|d)?\\s\\#\\d+",
          "github\\.com\\/.+\\/issues\\/\\d+"
        ]
      )
    end
  end

  describe "#valid?" do
    context "with no links" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test."]] }

      it "answers true" do
        expect(analyzer.valid?).to eq(true)
      end
    end

    ["fix #1", "Fix #12", "fixes #3", "Fixes #4", "fixed #5", "Fixed #6"].each do |line|
      context %(with "#{line}" link) do
        let(:commit) { GitPlus::Commit[body_lines: [line]] }

        it "answers false" do
          expect(analyzer.valid?).to eq(false)
        end
      end
    end

    ["close #1", "Close #12", "closes #3", "Closes #4", "closed #5", "Closed #6"].each do |line|
      context %(with "#{line}" link) do
        let(:commit) { GitPlus::Commit[body_lines: [line]] }

        it "answers false" do
          expect(analyzer.valid?).to eq(false)
        end
      end
    end

    [
      "resolve #1",
      "Resolve #12",
      "resolves #3",
      "Resolves #4",
      "resolved #5",
      "Resolved #6"
    ].each do |line|
      context %(with "#{line}" link) do
        let(:commit) { GitPlus::Commit[body_lines: [line]] }

        it "answers false" do
          expect(analyzer.valid?).to eq(false)
        end
      end
    end

    context "with GitHub link" do
      let :commit do
        GitPlus::Commit[
          body_lines: ["This completes issue [#45](https://github.com/test/test/issues/24)."]
        ]
      end

      it "answers false" do
        expect(analyzer.valid?).to eq(false)
      end
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    context "when valid" do
      let(:commit) { GitPlus::Commit[body_lines: ["Test."]] }

      it "answers empty hash" do
        expect(issue).to eq({})
      end
    end

    context "when invalid" do
      let :commit do
        GitPlus::Commit[
          body_lines: [
            "An example paragraph.",
            "This work fixes #22 using suggestions from team.",
            "See [Issue 22](https://github.com/test/project/issues/22)."
          ]
        ]
      end

      it "answers issue hint" do
        expect(issue[:hint]).to eq(
          "Explain issue instead of using link. Avoid: /(f|F)ix(es|ed)?\\s\\#\\d+/, " \
          "/(c|C)lose(s|d)?\\s\\#\\d+/, " \
          "/(r|R)esolve(s|d)?\\s\\#\\d+/, " \
          "/github\\.com\\/.+\\/issues\\/\\d+/."
        )
      end

      it "answers issue affected lines" do
        expect(issue[:lines]).to eq(
          [
            {number: 3, content: "This work fixes #22 using suggestions from team."},
            {number: 4, content: "See [Issue 22](https://github.com/test/project/issues/22)."}
          ]
        )
      end
    end
  end
end
