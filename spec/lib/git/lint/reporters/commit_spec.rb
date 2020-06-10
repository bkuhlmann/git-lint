# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Commit do
  let(:status) { instance_double Process::Status, success?: true }
  let(:shell) { class_spy Open3, capture2e: ["", status] }

  let :commit do
    object_double Git::Lint::Commits::Saved.new(sha: "abcdef", shell: shell),
                  sha: "abcdef",
                  author_name: "Test Tester",
                  author_date_relative: "1 day ago",
                  subject: "A test subject."
  end

  let :analyzer_class do
    class_spy Git::Lint::Analyzers::CommitAuthorEmail, label: "Commit Author Email"
  end

  let(:issue) { {hint: "A test hint."} }

  let :analyzer_instance do
    instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                 class: analyzer_class,
                 severity: :warn,
                 invalid?: invalid,
                 issue: issue
  end

  describe "#to_s" do
    context "with invalid analyzer" do
      subject(:reporter) { described_class.new commit: commit, analyzers: [analyzer_instance] }

      let(:invalid) { true }

      it "answers commit (SHA, author name, relative time, subject) and single analyzer report" do
        expect(reporter.to_s).to eq(
          "abcdef (Test Tester, 1 day ago): A test subject.\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n"
        )
      end
    end

    context "with invalid analyzers" do
      subject :reporter do
        described_class.new commit: commit, analyzers: [analyzer_instance, analyzer_instance]
      end

      let(:invalid) { true }

      it "answers commit (SHA, author name, relative time, subject) and multiple analyzer report" do
        expect(reporter.to_s).to eq(
          "abcdef (Test Tester, 1 day ago): A test subject.\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n"
        )
      end
    end

    context "with valid analyzers" do
      subject :reporter do
        described_class.new commit: commit, analyzers: [analyzer_instance, analyzer_instance]
      end

      let(:invalid) { false }

      it "empty string" do
        expect(reporter.to_s).to eq("")
      end
    end
  end
end
