# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Branch do
  subject(:reporter) { described_class.new collector:, total: }

  include_context "with Git commit"

  let(:collector) { Git::Lint::Collector.new }
  let(:total) { Git::Lint::Models::Total[items: 1] }

  describe "#empty?" do
    it "answers false" do
      expect(reporter.empty?).to be(false)
    end
  end

  describe "#issues?" do
    it "answers false" do
      expect(reporter.issues?).to be(false)
    end
  end

  describe "#warnings?" do
    it "answers false" do
      expect(reporter.warnings?).to be(false)
    end
  end

  describe "#errors?" do
    it "answers false" do
      expect(reporter.errors?).to be(false)
    end
  end

  describe "#to_s" do
    let :analyzer do
      instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                   class: class_spy(
                     Git::Lint::Analyzers::CommitAuthorEmail,
                     label: "Commit Author Email"
                   ),
                   commit: git_commit,
                   severity: "warn",
                   issue: {hint: "A test hint."}
    end

    context "with individual warnings" do
      let(:total) { Git::Lint::Models::Total[items: 1, issues: 1, warnings: 1] }

      it "answers totals" do
        collector.add analyzer

        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): Added documentation\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n" \
          "1 commit inspected. \e[33m1 issue\e[0m detected " \
          "(\e[33m1 warning\e[0m, \e[32m0 errors\e[0m).\n"
        )
      end
    end

    context "with individual errors" do
      let(:total) { Git::Lint::Models::Total[items: 1, issues: 1, errors: 1] }

      let :analyzer do
        instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                     class: class_spy(
                       Git::Lint::Analyzers::CommitAuthorEmail,
                       label: "Commit Author Email"
                     ),
                     commit: git_commit,
                     severity: "error",
                     issue: {hint: "A test hint."}
      end

      it "answers detected issues" do
        collector.add analyzer

        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): Added documentation\n" \
          "\e[31m  Commit Author Email Error. A test hint.\n\e[0m" \
          "\n" \
          "1 commit inspected. \e[31m1 issue\e[0m detected " \
          "(\e[32m0 warnings\e[0m, \e[31m1 error\e[0m).\n"
        )
      end
    end

    context "with group errors" do
      let(:total) { Git::Lint::Models::Total[items: 1, issues: 1, errors: 1] }

      let :analyzer do
        instance_spy Git::Lint::Analyzers::Commits::Subjects::Duplicate,
                     class: class_spy(
                       Git::Lint::Analyzers::Commits::Subjects::Duplicate,
                       label: "Commit Subject Duplicate"
                     ),
                     commit: nil,
                     commits: [git_commit, git_commit],
                     severity: "error",
                     issue: {hint: "A test hint."}
      end

      it "answers detected issues" do
        collector.add analyzer

        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "\e[31mCommit Subject Duplicate Error. A test hint.\n\e[0m" \
          "\n" \
          "1 commit inspected. \e[31m1 issue\e[0m detected " \
          "(\e[32m0 warnings\e[0m, \e[31m1 error\e[0m).\n"
        )
      end
    end

    context "without issues" do
      let(:total) { Git::Lint::Models::Total.new }

      it "answers zero detected issues" do
        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "0 commits inspected. \e[32m0 issues\e[0m detected.\n"
        )
      end
    end
  end

  describe "#to_str" do
    let(:total) { Git::Lint::Models::Total.new }

    it "answers implicit string" do
      expect(reporter.to_str).to eq(
        "Running Git Lint...\n" \
        "0 commits inspected. \e[32m0 issues\e[0m detected.\n"
      )
    end
  end
end
