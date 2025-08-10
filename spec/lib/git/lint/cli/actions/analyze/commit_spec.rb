# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Actions::Analyze::Commit do
  using Refinements::Pathname
  using Refinements::StringIO

  subject(:action) { described_class.new }

  include_context "with application dependencies"
  include_context "with Git repository"

  describe "#call" do
    before { allow(logger).to receive(:abort) }

    it "reports zero issues with valid SHA" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch b.txt && git add . && git commit --no-verify --message "Added A" --message "Test."`

        action.call

        expect(io.reread).to match(/.+1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "reports issue with invalid SHA" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch a.txt && git add . && git commit --no-verify --message "Add A"`

        action.call

        expect(io.reread).to match(
          /Commit Subject Prefix Error.+1 commit inspected.*1 issue.+detected/m
        )
      end
    end

    it "reports zero issues when given no SHAs" do
      allow(logger).to receive(:abort)

      git_repo_dir.change_dir do
        `rm -rf .git && git init`
        action.call
      end

      expect(logger).to have_received(:abort).with(
        "fatal: your current branch 'main' does not have any commits yet"
      )
    end

    it "aborts with invalid SHA" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt && git add . && git commit --no-verify --message "Add test file"`
        sha = `git log --pretty=format:%h -1`

        action.call sha

        expect(kernel).to have_received(:abort)
      end
    end

    it "logs error for failure" do
      analyzer = instance_double Git::Lint::Analyzer
      action = described_class.new(analyzer:)

      allow(analyzer).to receive(:call).and_raise(Git::Lint::Errors::Base, "Danger!")
      action.call

      expect(logger).to have_received(:abort).with "Danger!"
    end
  end
end
