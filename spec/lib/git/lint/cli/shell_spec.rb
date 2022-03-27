# frozen_string_literal: true

require "spec_helper"

RSpec.describe Git::Lint::CLI::Shell do
  using ::Refinements::Pathnames
  using AutoInjector::Stub

  subject(:shell) { described_class.new }

  include_context "with Git repository"
  include_context "with application dependencies"

  before { Git::Lint::CLI::Actions::Import.stub configuration:, kernel:, logger: }

  after { Git::Lint::CLI::Actions::Import.unstub :configuration, :kernel, :logger }

  describe "#call" do
    it "edits configuration" do
      shell.call %w[--config edit]
      expect(kernel).to have_received(:system).with(include("EDITOR"))
    end

    it "views configuration" do
      shell.call %w[--config view]
      expect(kernel).to have_received(:system).with(include("cat"))
    end

    it "analyzes feature branch with valid commits and reports no issues" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Added test file"`

        shell.call %w[--analyze]

        expect(kernel).to have_received(:puts).with(/1 commit inspected.*0 issues.+detected/m)
      end
    end

    it "analyzes feature branch with invalid commits and reports issues" do
      git_repo_dir.change_dir do
        `git switch --quiet --create test`
        `touch test.txt`
        `git add .`
        `git commit --no-verify --message "Add test file"`

        shell.call %w[--analyze]

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

        shell.call ["--analyze", "--sha", sha]

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

        shell.call ["--analyze", "--sha", sha]

        expect(kernel).to have_received(:puts).with(/1 commit inspected.*1 issue.+detected/m)
      end
    end

    it "analyzes hook for valid commit" do
      shell.call ["--hook", Bundler.root.join("spec/support/fixtures/commit-valid.txt").to_s]
      expect(kernel).to have_received(:puts).with(/1 commit inspected.*0 issues.+detected/m)
    end

    it "analyzes hook for invalid commit" do
      shell.call ["--hook", Bundler.root.join("spec/support/fixtures/commit-invalid.txt").to_s]

      expect(kernel).to have_received(:puts).with(
        /1 commit inspected.+4 issues.+0 warnings.+4 errors/m
      )
    end

    it "prints help" do
      shell.call %w[--help]
      expect(logger.reread).to match(/Git Lint.+USAGE.+/m)
    end

    it "prints usage when no options are given" do
      shell.call
      expect(logger.reread).to match(/Git Lint.+USAGE.+/m)
    end

    it "prints error with invalid option" do
      shell.call %w[--bogus]
      expect(logger.reread).to match(/invalid option.+bogus/)
    end

    it "prints version" do
      shell.call %w[--version]
      expect(logger.reread).to match(/Git Lint\s\d+\.\d+\.\d+/)
    end
  end
end
