# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Branch do
  subject(:reporter) { described_class.new }

  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "abcdef", shell: shell),
                  sha: "abcdef",
                  author_name: "Test Tester",
                  author_date_relative: "1 day ago",
                  subject: "A subject."
  end

  let(:issue) { {hint: "A test hint."} }

  let :analyzer_class do
    class_spy Git::Lint::Analyzers::CommitAuthorEmail, label: "Commit Author Email"
  end

  describe "#to_s" do
    context "with warnings" do
      subject(:reporter) { described_class.new collector: collector }

      let(:collector) { Git::Lint::Collector.new }

      let :analyzer_instance do
        instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                     class: analyzer_class,
                     commit: commit,
                     severity: :warn,
                     invalid?: true,
                     warning?: true,
                     error?: false,
                     issue: issue
      end

      before { collector.add analyzer_instance }

      it "answers detected issues" do
        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "abcdef (Test Tester, 1 day ago): A subject.\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n" \
          "1 commit inspected. \e[33m1 issue\e[0m detected " \
          "(\e[33m1 warning\e[0m, \e[32m0 errors\e[0m).\n"
        )
      end
    end

    context "with errors" do
      subject(:reporter) { described_class.new collector: collector }

      let(:collector) { Git::Lint::Collector.new }

      let :analyzer_instance do
        instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                     class: analyzer_class,
                     commit: commit,
                     severity: :error,
                     invalid?: true,
                     warning?: false,
                     error?: true,
                     issue: issue
      end

      before do
        collector.add analyzer_instance
        collector.add analyzer_instance
      end

      it "answers detected issues" do
        expect(reporter.to_s).to eq(
          "Running Git Lint...\n" \
          "\n" \
          "abcdef (Test Tester, 1 day ago): A subject.\n" \
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
end
