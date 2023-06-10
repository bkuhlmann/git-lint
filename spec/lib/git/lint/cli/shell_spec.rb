# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Shell do
  using Refinements::Pathnames
  using Infusible::Stub

  subject(:shell) { described_class.new }

  include_context "with Git repository"
  include_context "with application dependencies"

  before { Sod::Import.stub kernel:, logger: }

  after { Sod::Import.unstub :kernel, :logger }

  describe "#call" do
    it "prints configuration usage" do
      shell.call %w[config]
      expect(kernel).to have_received(:puts).with(/Manage configuration.+/m)
    end

    it "analyzes feature branch with valid commits and reports no issues" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Added test file"`

        shell.call %w[analyze --branch]

        expect(kernel).to have_received(:puts).with(/1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "analyzes feature branch with invalid commits and reports issues" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Add test file"`

        shell.call %w[analyze --branch]

        expect(kernel).to have_received(:puts).with(
          /Commit Subject Prefix Error.+1 commit inspected.*1 issue.+detected/m
        )
      end
    end

    it "analyzes feature branch with valid SHA and reports no issues" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Added test file"`
        sha = `git log --pretty=format:%h -1`

        shell.call ["analyze", "--commit", sha]

        expect(kernel).to have_received(:puts).with(/1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "analyzes feature branch with invalid SHA and reports issue" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Add test"`
        sha = `git log --pretty=format:%h -1`

        shell.call ["analyze", "--commit", sha]

        expect(kernel).to have_received(:puts).with(/1 commit inspected.*1 issue.+detected/m)
      end
    end

    it "analyzes hook for valid commit" do
      shell.call ["--hook", SPEC_ROOT.join("support/fixtures/commit-valid.txt").to_s]
      expect(kernel).to have_received(:puts).with(/1 commit inspected.*0 issues.+detected/m)
    end

    it "analyzes hook for invalid commit" do
      shell.call ["--hook", SPEC_ROOT.join("support/fixtures/commit-invalid.txt").to_s]

      expect(kernel).to have_received(:puts).with(
        /1 commit inspected.+2 issues.+0 warnings.+2 errors/m
      )
    end

    it "prints version" do
      shell.call %w[--version]
      expect(kernel).to have_received(:puts).with(/Git Lint\s\d+\.\d+\.\d+/)
    end

    it "prints help" do
      shell.call %w[--help]
      expect(kernel).to have_received(:puts).with(/Git Lint.+USAGE.+/m)
    end
  end
end
