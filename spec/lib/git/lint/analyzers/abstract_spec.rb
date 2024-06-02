# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Analyzers::Abstract do
  using Refinements::Struct

  subject(:analyzer) { described_class.new git_commit }

  include_context "with application dependencies"
  include_context "with Git commit"

  describe ".id" do
    it "answers class ID" do
      expect(described_class.id).to eq("abstract")
    end
  end

  describe ".label" do
    it "answers class label" do
      expect(described_class.label).to eq("Abstract")
    end
  end

  describe ".build_issue_line" do
    it "answers isuse line" do
      expect(described_class.build_issue_line(1, "Test.")).to eq(number: 4, content: "Test.")
    end
  end

  describe "#severity" do
    subject(:analyzer) { Git::Lint::Analyzers::CommitSubjectPrefix.new git_commit }

    it "answers severity when severity is defined" do
      expect(analyzer.severity).to eq("error")
    end

    it "fails without severity" do
      analyzer = Git::Lint::Analyzers::CommitSubjectPrefix.new(
        git_commit,
        settings: settings.merge(commits_subject_prefix_severity: nil)
      )
      result = -> { analyzer.severity }

      expect(&result).to raise_error(Git::Lint::Errors::Severity, /invalid severity/i)
    end

    it "fails with invalid severity error" do
      analyzer = Git::Lint::Analyzers::CommitSubjectPrefix.new(
        git_commit,
        settings: settings.merge(commits_subject_prefix_severity: :bogus)
      )
      result = -> { analyzer.severity }

      expect(&result).to raise_error(Git::Lint::Errors::Severity, /invalid severity.+bogus/i)
    end
  end

  describe "#valid?" do
    it "fails with no method error" do
      result = -> { analyzer.valid? }
      expect(&result).to raise_error(NoMethodError, /.+\#valid\?.+/)
    end
  end

  describe "#invalid?" do
    let :valid_analyzer do
      Class.new described_class do
        def valid? = true
      end
    end

    let :invalid_analyzer do
      Class.new described_class do
        def valid? = false
      end
    end

    it "answers true when not valid" do
      expect(invalid_analyzer.new(git_commit).invalid?).to be(true)
    end

    it "answers false when valid" do
      expect(valid_analyzer.new(git_commit).invalid?).to be(false)
    end

    it "fails with no method error when not implemented" do
      result = -> { analyzer.invalid? }
      expect(&result).to raise_error(NoMethodError, /.+\#valid\?.+/)
    end
  end

  describe "#warning?" do
    let :analyzer do
      Git::Lint::Analyzers::CommitSubjectPrefix.new(
        git_commit,
        settings: settings.merge(commits_subject_prefix_severity: "warn")
      )
    end

    it "answers true when invalid" do
      allow(analyzer).to receive(:valid?).and_return(false)
      expect(analyzer.warning?).to be(true)
    end

    it "answers false when valid" do
      allow(analyzer).to receive(:valid?).and_return(true)
      expect(analyzer.warning?).to be(false)
    end

    it "fails with no method error when not implemented" do
      result = -> { described_class.new(git_commit).warning? }
      expect(&result).to raise_error(NoMethodError, /.+\#valid\?.+/)
    end
  end

  describe "#error?" do
    let :analyzer do
      Git::Lint::Analyzers::CommitSubjectPrefix.new(
        git_commit,
        settings: settings.merge(commits_subject_prefix_severity: "error")
      )
    end

    it "answers true when invalid" do
      allow(analyzer).to receive(:valid?).and_return(false)
      expect(analyzer.error?).to be(true)
    end

    it "answers false when valid" do
      allow(analyzer).to receive(:valid?).and_return(true)
      expect(analyzer.error?).to be(false)
    end

    it "fails with no method error when not implemented" do
      result = -> { described_class.new(git_commit).error? }
      expect(&result).to raise_error(NoMethodError, /.+\#valid\?.+/)
    end
  end

  describe "#issue" do
    it "fails with no method error" do
      result = -> { analyzer.issue }
      expect(&result).to raise_error(NoMethodError, /.+\#issue.+/)
    end
  end
end
