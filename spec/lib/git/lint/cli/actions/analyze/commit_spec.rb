# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Actions::Analyze::Commit do
  using Refinements::Pathnames

  subject(:action) { described_class.new }

  include_context "with application dependencies"
  include_context "with Git repository"

  describe "#call" do
    it "reports zero issues with valid SHA" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch b.txt && git add . && git commit --no-verify --message "Added A" --message "Test."`
        sha = `git log --pretty=format:%h -1`

        action.call sha

        expect(kernel).to have_received(:puts).with(/.+1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "reports issue with invalid SHA" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch a.txt && git add . && git commit --no-verify --message "Add A"`
        sha = `git log --pretty=format:%h -1`

        action.call sha

        expect(kernel).to have_received(:puts).with(
          /Commit Subject Prefix Error.+1 commit inspected.*1 issue.+detected/m
        )
      end
    end

    it "reports zero issues when given no SHAs" do
      git_repo_dir.change_dir do
        `rm -rf .git && git init`
        action.call
        expect(kernel).to have_received(:puts).with(/.+0 commits inspected.*0 issues.+detected/m)
      end
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

    context "with failure" do
      subject(:action) { described_class.new analyzer: }

      let(:analyzer) { instance_double Git::Lint::Analyzer }

      before { allow(analyzer).to receive(:call).and_raise(Git::Lint::Errors::Base, "Danger!") }

      it "logs error" do
        action.call
        expect(logger.reread).to eq("Danger!\n")
      end

      it "aborts" do
        action.call
        expect(kernel).to have_received(:abort)
      end
    end
  end
end
