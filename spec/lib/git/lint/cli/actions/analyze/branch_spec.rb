# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Actions::Analyze::Branch do
  using Refinements::Pathname
  using Refinements::StringIO

  subject(:action) { described_class.new }

  include_context "with application dependencies"
  include_context "with Git repository"

  describe "#call" do
    before { allow(logger).to receive(:abort) }

    it "reports no issues with valid commits" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt && git add .`
        `git commit --no-verify --message "Added test file" --message "For testing purposes."`

        action.call

        expect(io.reread).to match(/1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "reports issues with invalid commits" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt && git add .`
        `git commit --no-verify --message "Add test file"`

        action.call

        expect(io.reread).to match(
          /Commit Subject Prefix Error.+1 commit inspected.*1 issue.+detected/m
        )
      end
    end

    it "aborts with invalid commits" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt && git add .`
        `git commit --no-verify --message "Add test file"`

        action.call

        expect(kernel).to have_received(:abort)
      end
    end

    it "logs error for failure" do
      analyzer = instance_double Git::Lint::Analyzer
      action = described_class.new(analyzer:)

      allow(analyzer).to receive(:call).and_raise(Git::Lint::Errors::Base, "Danger!")
      action.call

      expect(logger).to have_received(:abort).with("Danger!")
    end
  end
end
