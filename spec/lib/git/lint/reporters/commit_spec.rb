# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::Reporters::Commit do
  include_context "with Git commit"

  describe "#to_s" do
    let :analyzer do
      instance_spy Git::Lint::Analyzers::CommitAuthorEmail,
                   class: class_spy(
                     Git::Lint::Analyzers::CommitAuthorEmail,
                     label: "Commit Author Email"
                   ),
                   severity: :warn,
                   invalid?: invalid,
                   issue: {hint: "A test hint."}
    end

    context "with invalid analyzer" do
      subject(:reporter) { described_class.new commit: git_commit, analyzers: [analyzer] }

      let(:invalid) { true }

      it "answers commit (SHA, author name, relative time, subject) and single analyzer report" do
        expect(reporter.to_s).to eq(
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): " \
          "Added documentation\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n"
        )
      end
    end

    context "with invalid analyzers" do
      subject(:reporter) { described_class.new commit: git_commit, analyzers: [analyzer, analyzer] }

      let(:invalid) { true }

      it "answers commit (SHA, author name, relative time, subject) and multiple analyzer report" do
        expect(reporter.to_s).to eq(
          "180dec7d8ae8cbe3565a727c63c2111e49e0b737 (Test User, 1 day ago): " \
          "Added documentation\n" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\e[33m  Commit Author Email Warning. A test hint.\n\e[0m" \
          "\n"
        )
      end
    end

    context "with valid analyzers" do
      subject(:reporter) { described_class.new commit: git_commit, analyzers: [analyzer, analyzer] }

      let(:invalid) { false }

      it "empty string" do
        expect(reporter.to_s).to eq("")
      end
    end
  end
end
