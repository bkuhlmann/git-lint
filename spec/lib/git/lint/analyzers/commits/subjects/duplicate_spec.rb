# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Commits::Subjects::Duplicate do
  using Refinements::Struct

  subject(:analyzer) { described_class.new commits }

  let(:commits) { [git_commit.with(sha: "aaa"), git_commit.with(sha: "bbb")] }

  include_context "with application dependencies"
  include_context "with Git commit"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("commits_subject_duplicate")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Commit Subject Duplicate")
    end
  end

  describe "#valid?" do
    it "answers true with no commits" do
      commits.clear
      expect(analyzer.valid?).to be(true)
    end

    it "answers true without duplicates" do
      commits.pop
      expect(analyzer.valid?).to be(true)
    end

    it "answers true with duplicate amends" do
      commits.clear.push git_commit.with(subject: "amend! Test"),
                         git_commit.with(subject: "amend! Test")

      expect(analyzer.valid?).to be(true)
    end

    it "answers true with duplicate fixups" do
      commits.clear.push git_commit.with(subject: "fixup! Test"),
                         git_commit.with(subject: "fixup! Test")

      expect(analyzer.valid?).to be(true)
    end

    it "answers true with duplicate squashes" do
      commits.clear.push git_commit.with(subject: "squash! Test"),
                         git_commit.with(subject: "squash! Test")

      expect(analyzer.valid?).to be(true)
    end

    it "answers false with duplicates" do
      expect(analyzer.valid?).to be(false)
    end

    it "answers false with multiple duplicates" do
      commits.append git_commit.with(sha: "ccc")
      expect(analyzer.valid?).to be(false)
    end
  end

  describe "#issue" do
    let(:issue) { analyzer.issue }

    it "answers empty hash when valid" do
      commits.pop
      expect(issue).to eq({})
    end

    context "when invalid" do
      let(:commit) { Gitt::Models::Commit[author_name: "example"] }

      it "answers issue hint" do
        expect(issue).to eq(
          hint: "Use unique subjects.",
          references: ["aaa Added documentation", "bbb Added documentation"]
        )
      end
    end
  end
end
