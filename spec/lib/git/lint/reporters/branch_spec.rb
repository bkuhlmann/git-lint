# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Branch do
  subject(:reporter) { described_class.new collector: }

  include_context "with Git commit"

  let(:collector) { Git::Lint::Collector.new }

  describe "#to_s" do
    let :analyzer do
      instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                   class: class_spy(
                     Git::Lint::Analyzers::CommitAuthorEmail,
                     label: "Commit Author Email"
                   ),
                   commit: git_commit,
                   severity: :warn,
                   invalid?: true,
                   warning?: true,
                   error?: false,
                   issue: {hint: "A test hint."}
    end

    context "with warnings" do
      before { collector.add analyzer }

      it "answers detected issues" do
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

    context "with errors" do
      let :analyzer do
        instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                     class: class_spy(
                       Git::Lint::Analyzers::CommitAuthorEmail,
                       label: "Commit Author Email"
                     ),
                     commit: git_commit,
                     severity: :error,
                     invalid?: true,
                     warning?: false,
                     error?: true,
                     issue: {hint: "A test hint."}
      end

      before do
        collector.add analyzer
        collector.add analyzer
      end

      it "answers detected issues" do
        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): Added documentation\n" \
          "\e[31m  Commit Author Email Error. A test hint.\n\e[0m" \
          "\e[31m  Commit Author Email Error. A test hint.\n\e[0m" \
          "\n" \
          "1 commit inspected. \e[31m2 issues\e[0m detected " \
          "(\e[32m0 warnings\e[0m, \e[31m2 errors\e[0m).\n"
        )
      end
    end

    context "without issues" do
      it "answers zero detected issues" do
        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "0 commits inspected. \e[32m0 issues\e[0m detected.\n"
        )
      end
    end
  end

  describe "#to_str" do
    it "answers implicit string" do
      expect(reporter.to_str).to eq(
        "Running Git Lint...\n" \
        "0 commits inspected. \e[32m0 issues\e[0m detected.\n"
      )
    end
  end
end
